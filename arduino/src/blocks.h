#include <Arduino.h>

typedef struct AND
{
    uint8_t IN1 : 1 ;
    uint8_t IN2 : 1 ;
    uint8_t IN3 : 1 ;
    uint8_t Q   : 1 ;
} AND_GATE ;

typedef struct OR
{
    uint8_t IN1 : 1 ;
    uint8_t IN2 : 1 ;
    uint8_t IN3 : 1 ;
    uint8_t Q   : 1 ;
} OR_GATE ;

typedef struct SR
{
    uint8_t S : 1 ;
    uint8_t R : 1 ;
    uint8_t Q   : 1 ;
} SR_GATE ;

typedef struct DELAY  // MAY NEED TO BECOME A CLASS IN ORDER TO HANDLE THE ACTUAL TIMING PART..
{
    uint8_t         IN : 1 ;
    uint8_t         Q : 1 ;
    uint32_t        oldTime ;
    const uint32_t  interval ; // const possible?
} DELAY_GATE ;

typedef struct NOT
{
    uint8_t IN : 1 ;
    uint8_t Q  : 1 ;
} NOT_GATE ;


AND_GATE     and_gate[ n_and_gates ] ;
OR_GATE       or_gate[ n_or_gates ] ;
SR_GATE       sr_gate[ n_sr_gates ] ;
DELAY_GATE delay_gate[ n_delay_gates ] ;
NOT_GATE     not_gate[ n_not_gates ] ;

// demo code...

void setup()
{

}

void loop()
{

    // INPUTS
    for( int i = 0 ; i < n_inputs  ; i ++ ) input[i].Q = digitalRead( input[i].pin ) ;

    // OUTPUTS
    for( int i = 0 ; i < n_inputs  ; i ++ )
    {
        digitalWrite( output[i].pin, output[i].in2 ) ;
    }

    // AND GATES
    for( int i = 0 ; i < n_and_gates  ; i ++ )
    {
        and_gate[i].Q = and_gate[i].in1 & and_gate[i].in2 & and_gate[i].in3 ;
    }

    // OR GATES
    for( int i = 0 ; i < n_or_gates  ; i ++ )
    {
        or_gate[i].Q = or_gate[i].in1 | or_gate[i].in2 | or_gate[i].in3 ;
    }

    // SR MEMORY GATES
    for( int i = 0 ; i < n_sr_gates  ; i ++ )
    {
        if(      sr_gate[i].R ) sr_gate[i].Q = 0 ;    // reset is dominant
        else if( sr_gate[i].S ) sr_gate[i].Q = 1 ;
    }

    // DELAY
    for( int i = 0 ; i < n_delay_gates  ; i ++ )
    {
        if( delay_gate[i].Q != delay_gate[i].IN )                                   // if new state changes
        {
            if( millis() - delay_gate[i].oldTime >= delay_gate[i].interval )         // keep monitor if interval has expired
            {
                delay_gate[i].Q = delay_gate[i].IN ;                                // if so, adopt the new state
            }
        }
        else
        {
            delay_gate[i].oldTime = millis() ;                                      // if new state does not change, keep setting oldTime
        }
    }

    // NOT
    for( int i = 0 ; i < n_not_gates  ; i ++ )
    {
        not_gate[i].Q = !not_gate[i].IN ;
    }
    // add links

} ;

// demo links between blocks, every IN line, should have a link     // NOTE. This can also be done by using an array of links and pointers.
                                                                    //  In the main loop all links can be handled by a for loop. It will take more time to process though...
                                                                    //  the main difference is that the linkage info is moved from loop to constructors.. 
                                                                    //  so if you gain anything by it? I doubt it
delay_gate[1].IN    = and_gate[2].Q ;
delay_gate[2].IN    = and_gate[4].Q ;
delay_gate[3].IN    = and_gate[6].Q ;

or_gate[1].IN1      = sr_gate[1].Q ;
or_gate[1].IN2      = sr_gate[2].Q ;
or_gate[2].IN1      = or_gate[1].Q ;
or_gate[2].IN2      = or_gate[2].Q ;

sr_gate[2]          = input[5].Q ;
or_gate[4]          = sr_gate[2].Q ;
