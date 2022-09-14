const int n_inputs      = 2 ;
const int n_outputs     = 0 ;
const int n_and_gates   = 1 ;
const int n_or_gates    = 1 ;
const int n_sr_gates    = 2 ;
const int n_delay_gates = 2 ;
const int n_not_gates   = 1 ;

typedef struct INPUT
{
    uint8_t PIN ;
    uint8_t Q : 1 ;
} INPUT_PIN ;

typedef struct OUTPUT
{
    uint8_t PIN ;
    uint8_t IN : 1 ;
} OUTPUT_PIN ;

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

INPUT_PIN        input[      n_inputs ] ;
OUTPUT_PIN      output[     n_outputs ] ;
AND_GATE      and_gate[   n_and_gates ] ;
OR_GATE        or_gate[    n_or_gates ] ;
SR_GATE        sr_gate[    n_sr_gates ] ;
DELAY_GATE  delay_gate[ n_delay_gates ] ;
NOT_GATE      not_gate[   n_not_gates ] ;

void setup()
{

}

void loop()
{

    // INPUTS
    for( int i = 0 ; i < n_inputs  ; i ++ ) input[i].Q = digitalRead( input[i].PIN ) ;

    // OUTPUTS
    for( int i = 0 ; i < n_inputs  ; i ++ )
    {
        digitalWrite( output[i].PIN, output[i].IN ) ;
    }

    // AND GATES
    for( int i = 0 ; i < n_and_gates  ; i ++ )
    {
        and_gate[i].Q = and_gate[i].IN1 & and_gate[i].IN2 & and_gate[i].IN3 ;
    }

    // OR GATES
    for( int i = 0 ; i < n_or_gates  ; i ++ )
    {
        or_gate[i].Q = or_gate[i].IN1 | or_gate[i].IN2 | or_gate[i].IN3 ;
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
