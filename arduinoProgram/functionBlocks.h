#include <Arduino.h>
#include <Servo.h>


extern void    sendMessage( String S )  __attribute__((weak)) ;
extern String  getMessage()             __attribute__((weak)) ;
extern uint8_t getDCCstate( uint16_t )  __attribute__((weak)) ;

uint8_t outputEnabled = 0 ;

const int ANALOG_SAMPLE_TIME = 20 ;

void inline startDelay()
{
    if( outputEnabled == 0
    &&  millis() > 50 )   // wait this time before output blocks are enabled
    {
        outputEnabled = 1 ;
    } 
}

class DigitalBlock
{
public:
    uint8_t    IN1 : 1 ;
    uint8_t    IN2 : 1 ;
    uint8_t    IN3 : 1 ;
    uint8_t      Q : 1 ;
    uint8_t  Q_NOT : 1 ;

    virtual void run() ;
} ;

class Rising: public DigitalBlock
{
public:
    void run()
    {
        if( Q == 1 )                                                            // if pulse is active...
        {
            if( millis() - prevTime >= interval ) Q = 0 ;                       // kill Q after 20ms ( <== pulse length )
        }
        else if( IN2 != IN_prev )
        {        IN_prev = IN2 ;

            if( IN2 )                                                           // if rising flank, set Q
            {
                prevTime = millis() ;
                Q = 1 ;
            }
        }
    }
private:
    uint32_t       prevTime ;
    uint8_t        IN_prev  ;
    const uint32_t interval = 20 ;
} ;

class Falling: public DigitalBlock
{
public:
    void run()
    {
        if( Q == 1 )                                                            // if pulse is active...
        {
            if( millis() - prevTime >= interval ) Q = 0 ;                       // kill Q after 20ms ( <== pulse length )
        }
        else if( IN2 != IN_prev )
        {        IN_prev = IN2 ;

            if( IN2 == 0 )                                                      // if falling flank, set Q
            {
                prevTime = millis() ;
                Q = 1 ;
            }
        }
    }
private:
    uint32_t       prevTime ;
    uint8_t        IN_prev  ;
    const uint32_t interval = 20 ;
} ;

class And : public DigitalBlock
{
public:
    And()
    {
        IN1 = IN2 = IN3 = 1 ;
    }
    void run()
    {
        Q = IN1 & IN2 & IN3 ;
    }
} ;

class Jk : public DigitalBlock
{
public:
    Jk()
    {
        IN1 = IN2 = 1 ;         // init both J and K to '1'
        IN3 = prevLatch = 0 ;
    }

    void run()
    {
        if( prevLatch != IN3 )
        {   prevLatch  = IN3 ;

            if( IN3 )                               // if rising flank
            {
                if( IN1 & IN2 ) Q = !Q ;            // if both J and K are '1' -> toggle Q
                else if( IN1 )  Q =  1 ;            // if only J is true, set Q
                else            Q =  0 ;            // if only K is true, clear Q

            }
        }
    }

private:
    uint8_t prevLatch : 1 ;
} ;

class Pulse : public DigitalBlock
{
public:
    Pulse(int x) : toggleTime( x )                       // initialize the constant
    {
    }

    void run()
    {
        if( millis() - prevTime >= toggleTime )
        {       prevTime = millis() ;

            Q = !Q ;
        }
    }

private:
    const uint32_t  toggleTime ;
    uint32_t        prevTime ;
} ;


class Or : public DigitalBlock
{
public:
    Or()
    {
        IN1 = IN2 = IN3 = 0 ;
    }

    void run()
    {
        Q = IN1 | IN2 | IN3 ;
    }
} ;

class Memory : public DigitalBlock
{
public:

    void run()
    {
        if(      IN3 == 1 ) Q = 0 ; // R
        else if( IN1 == 1 ) Q = 1 ; // S
    }
} ;

class Not : public DigitalBlock
{
public:

    void run()
    {
        Q = !IN2 ;
    }
} ;

class SerialOut : public DigitalBlock
{
public:
    SerialOut( String S) : message( S )
    {
    }

    void run()
    {
        if( outputEnabled && IN2 != Q )
        {     
            Q = IN2 ;
            if( Q ) 
            {
                sendMessage( message ) ;
            }
        }
    }
    
private:
    const String message ;
} ;

class SerialIn : public DigitalBlock
{
public:
    SerialIn( String S) : message( S )
    {
    }

    void run()
    {
        //Serial.print("my message: "); Serial.print(message) ; Serial.print(" received message: "); Serial.println( getMessage() ) ;
        if( message == getMessage() ) Q = 1 ;
        else                          Q = 0 ;
    }

private:
    const String message ;
} ;

class DCC: public DigitalBlock
{
public:
    DCC( uint16_t _address )
    {
        address = _address ;
    }

    void run()
    {
        uint8_t state  = getDCCstate( address ) ;
        if( state == 0 ) Q = 0 ;
        if( state == 1 ) Q = 1 ;
        // state can be 2, which means different address is set -> no change for my Q
    }

private:
    uint16_t address ;
} ;

class Input : public DigitalBlock
{
public:
    Input( uint8_t _pin )
    {
        pin = _pin ;
        pinMode( pin, INPUT_PULLUP ) ;
    }

    void run()
    {
        uint8_t state = digitalRead( pin ) ;

        if( Q != state )                                 // if new state differs with old state
        {
            if( millis() - prevTime >= debounceTime )       // keep monitor if interval has expired
            {
                Q = state ;
            }
        }
        else
        {
            prevTime = millis() ;
        }        
    }

private:
    const uint32_t  debounceTime = 20 ;
    uint32_t        prevTime ;
    uint8_t         pin ;
} ;

class Output : public DigitalBlock
{
public:
    Output ( uint8_t _pin )
    {
        pin = _pin ;
        pinMode( pin, OUTPUT ) ;
    }

    uint8_t pin ;

    void run()
    {
        digitalWrite( pin, IN2 & outputEnabled ) ;
    }
} ;

class AnalogBlock
{
public:
    uint16_t    IN1 ;
    uint16_t    IN2 ;
    uint16_t    IN3 ;
    uint16_t      Q ;

    virtual void run() ;
} ;

class Delay : public AnalogBlock
{
public:
    Delay(int x) : delayTime( x )                        // initialize the constant
    {
    }

    void run()
    {
        if( Q != IN2 )                                   // if new state changes
        {
            if( millis() - prevTime >= delayTime )       // keep monitor if interval has expired
            {
                if( IN2 < Q ) Q -- ;                     // if so, adopt the new state
                if( IN2 > Q ) Q ++ ;
                //Serial.println(Q) ;
                prevTime = millis() ;
            }
        }
        else
        {
            prevTime = millis() ;                        // if new state does not change, keep setting oldTime
        }
    }

private:
    const uint32_t delayTime ;
    uint32_t       prevTime ;
} ;

class Comperator : public AnalogBlock
{
public:
    void run()
    {
        if( IN1 > IN3 + 2 ) Q = 1 ;   // marge of 2 for schmitt-trigger effect, may need to more like 5..
        if( IN1 < IN3 - 2 ) Q = 0 ; 
    }
} ;


class Constant : public AnalogBlock
{
public:
    Constant( uint32_t val )
    {
        Q = val ;
    }

    void run()
    {

    }
} ;


class AnalogInput : public AnalogBlock
{
public:

    AnalogInput( uint8_t _pin )
    {
        pin = _pin ;
    }

    uint8_t pin ;

    void run()
    {
        if( millis() - prevTime >= sampleRate ) 
        {     prevTime = millis() ;

            Q = analogRead( pin ) ;
        }
    }

private:
    const uint32_t sampleRate = ANALOG_SAMPLE_TIME ;
    uint32_t       prevTime ;
} ;

class AnalogOutput : public AnalogBlock
{
public:

    AnalogOutput( uint8_t _pin ) : pin( _pin )
    {        
    }

    void run()
    {
        if( outputEnabled == 0 ) return ;

        if( IN2 != prevIn )
        {   prevIn  = IN2 ;                // if incomming change, update PWM level

            analogWrite( pin, IN2) ;
        }
    }
  
private:
    const uint8_t pin ;
    uint8_t       prevIn ;
} ;

class ServoMotor : public AnalogBlock
{
public:
    ServoMotor( uint8_t _pin ) 
    {
        pin = _pin ;
        IN3 = 1 ;                   // not used is always on
    }

    void run()
    {
        if( outputEnabled == 0 ) return ; 

        if( servoPos != IN2 && IN3 == 1 ) // In3 acts as a latch pin
        {   servoPos  = IN2 ;

            fallOffTime = millis() ;
        
            servoPos = constrain( servoPos, 0, 180 ) ;
            motor.write( servoPos ) ;

            if( motor.attached() == 0 ) motor.attach(pin) ;
        }
        else if( millis() - fallOffTime >= 500 )
        {
            motor.detach() ;
        }
    }

private:
    Servo motor ;
    uint8_t servoPos ;
    uint32_t fallOffTime ;
    uint8_t pin : 7 ;
} ;


class Map : public AnalogBlock
{
public:
    Map( int32_t x1, int32_t x2 , int32_t x3, int32_t x4 ) 
        :  in1( x1 ), 
           in2( x2 ),
          out1( x3 ), 
          out2( x4 )
    {}

    void run()
    {
        Q = map( IN2, in1, in2, out1, out2 ) ;
    }

private:
    const int32_t  in1 ;
    const int32_t  in2 ;
    const int32_t out1 ;
    const int32_t out2 ;
} ;

class Equals : public AnalogBlock
{
public:
    void run()
    {
        if( IN1 == IN3 ) Q = 1 ;
        else             Q = 0 ;
    }
} ;

class Add : public AnalogBlock
{
public:
    void run()
    {
        Q = IN1 + IN3 ;
    }
} ;

class Sub : public AnalogBlock
{
public:
    void run()
    {
        Q = IN1 - IN3 ;
    }
} ;

class Mul : public AnalogBlock
{
public:
    void run()
    {
        Q = IN1 * IN3 ;
    }
} ;

class Div : public AnalogBlock
{
public:
    void run()
    {
        Q = IN1 / IN3 ;
    }
} ;


/*
class Constant : public AnalogBlock     // I really should not do this, but try to hardcode the constants in the .ino file instead
{                                       // This uses atleast 12 bytes of memory when a constant does not use bytes in the first place
public:
    Constant(int x) : val( x )
    {
    }

    void run()
    {
        Q = x ;
    }

private:
    const int val ;
}

#define REPEAT_US(x)    { \
                            static uint32_t previousTime ;\
                            uint32_t currentTime = micros() ;\
                            if( currentTime  - previousTime >= x ) {\
                                previousTime = currentTime ;
                                // code to be repeated goes between these 2 macros
#define REPEAT_MS(x)    { \
                            static uint32_t previousTime ;\
                            uint32_t currentTime = millis() ;\
                            if( currentTime  - previousTime >= x ) {\
                                previousTime = currentTime ;
                                // code to be repeated goes between these 2 macros
#define END_REPEAT          } \
                        }
        */