#include <Arduino.h>
#include <Servo.h>

const int ANALOG_SAMPLE_TIME = 20 ;

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
        if( IN2 != Q )
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
}

class SerialIn : public DigitalBlock
{
public:
    SerialIn( String S) : message( S )
    {
    }

    void run()
    {
        if( message == getMessage() ) Q = 1 ;
        else                          Q = 0 ;
    }

private:
    const String message ;
}

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
        digitalWrite( pin, IN2 ) ;
    }
} ;

class Delay : public DigitalBlock
{
public:
    Delay(int x) : delayTime( x )                       // initialize the constant
    {
    }

    void run()
    {
        if( Q != IN2 )                                   // if new state changes
        {
            if( millis() - prevTime >= delayTime )       // keep monitor if interval has expired
            {
                Q = IN2 ;                                // if so, adopt the new state
            }
        }
        else
        {
            prevTime = millis() ;                         // if new state does not change, keep setting oldTime
        }
    }

private:
    const uint32_t delayTime ;
    uint32_t       prevTime ;
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

class Comperator : public AnalogBlock
{
public:
    void run()
    {
        if( IN1 > IN2 + 2 ) Q = 1 ;   // marge of 2 for schmitt-trigger
        if( IN1 < IN2 - 2 ) Q = 0 ; 
    }
}

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

            analogQ = analogRead( pin ) ;
        }
    }

    int analogQ ;

private:
    const uint32_t sampleRate = ANALOG_SAMPLE_TIME ;
    uint32_t       prevTime ;
} ;

class AnalogOutput : public AnalogBlock
{
public:

    AnalogOutput( uint8_t _pin )
    {
        pin = _pin ;
    }

    uint8_t pin ;

    void run()
    {
        if( analogIN2 != prevIn )
        {   prevIn  = analogIN2 ;                // if incomming change, update PWM level

            analogWrite( pin, analogIN2 ) ;
            Serial.println( analogIN2 ) ; // DEBUG just testing if it... actually works
        }
    }

    uint8_t analogIN2 ;

private:
    uint8_t prevIn ;
} ;

class ServoMotor : public AnalogBlock
{
public:
    ServoMotor( uint8_t _pin ) 
    {
        pin = _pin ;
    }

    void init()
    {
        motor.attach(pin) ;
    }

    void run()
    {
        if( servoPos != analogIN2 )
        {   servoPos  = analogIN2 ;
        
            servoPos = constrain( servoPos, 0, 180 ) ;
            motor.write(servoPos) ;
        }
    }

    uint8_t analogIN2 ;

private:
    Servo motor ;
    uint8_t servoPos ;
    uint8_t pin ;
} ;


class Map : public AnalogBlock
{
    Map( uint32_t x1, uint32_t x2 , uint32_t x3, uint32_t x4 ) 
        :  in1( x1 ) 
        :  in2( x2 )
        : out1( x1 ) 
        : out2( x2 )
    {}

    void run()
    {               // IN2
        Q = map( IN2, in1, in2, out1, out2 ) ;
    }

    const uint32_t  in1 ;
    const uint32_t  in2 ;
    const uint32_t out1 ;
    const uint32_t out2 ;
} ;

extern void sendMessage( String S ) __attribute__((weak)) ;
extern String getMessage()          __attribute__((weak)) ;