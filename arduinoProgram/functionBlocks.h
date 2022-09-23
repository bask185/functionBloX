#define REPEAT_MS(x)    { \
                            static uint32_t previousTime ;\
                            uint32_t currentTime = millis() ;\
                            if( currentTime  - previousTime >= x ) {\
                                previousTime = currentTime ;
                                // code to be repeated goes between these 2 macros
#define END_REPEAT          } \
                        }

class FunctionBlock
{
public:
    uint8_t  IN1 : 1 ;
    uint8_t  IN2 : 1 ;
    uint8_t  IN3 : 1 ;
    uint8_t    Q : 1 ;

    virtual void run() ;
} ; 

class And : public FunctionBlock
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

class Jk : public FunctionBlock
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

class PulseGenerator : public FunctionBlock
{
public:
    PulseGenerator(int x) : toggleTime( x )                       // initialize the constant
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


class Or : public FunctionBlock
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

class Memory : public FunctionBlock
{
public:

    void run()
    {
        if(      IN3 == 1 ) Q = 0 ; // R
        else if( IN1 == 1 ) Q = 1 ; // S
    }
} ;

class Not : public FunctionBlock
{
public:

    void run()
    {
        Q = !IN2 ;
    }
} ;

class Input : public FunctionBlock
{
public:

    Input( uint8_t _pin )
    {
        pin = _pin ;
        pinMode( pin, INPUT_PULLUP ) ;
    }

    uint8_t pin ;

    void run()
    {
        Q = digitalRead( pin ) ;
    }
} ;

class Output : public FunctionBlock
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

class Delay : public FunctionBlock
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

class MAP : public FunctionBlock
{
    int32_t var ;   // result = map( var, in1, in2, out1, out2 ) ;
    int32_t result ;
    int32_t in1 ;
    int32_t in2 ;
    int32_t out1 ;
    int32_t out2 ;

    void run()
    {               // IN2
        result = map( var, in1, in2, out1, out2 ) ;
    }
} ;

