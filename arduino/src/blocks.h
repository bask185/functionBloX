const int nBlocks = 6 ;

typedef struct blox
{
    uint8_t  IN1 : 1 ;
    uint8_t  IN2 : 1 ;
    uint8_t  IN3 : 1 ;
    uint8_t    Q : 1 ;
    uint8_t  pin : 5 ;
    uint8_t type : 3 ; // 8 combinations, may not be enough in the future
    //uint32_t        oldTime ;  // bad idea to use this amount of memory per block if only delays need it?
    //const uint32_t  interval ; // perhaps couple a function pointers or obj pointer to it?
} FunctionBlock ;

FunctionBlock block [ nBlocks ] ;

enum blockTypes
{
       AND = 0,
        OR, 
         M, 
       DEL, 
       NOT, 
     INPUT,
    OUTPUT,
} ;

void setup()
{
    for( int i = 0 ; i < nBlocks ; i ++ )
    {
        switch( block[i].type )
        {
        case AND: 
            block[i].IN1 = block[i].IN2 = block[i].IN3 = 1 ; // force all AND gate INs to be 1 in case of unused things
            break ;

        case INPUT:
            pinMode( block[i].pin, INPUT_PULLUP ) ;
            break ;

        case OUTPUT:
            pinMode( block[i].pin, OUTPUT ) ;
            break ;

        case DEL:       // idk do something clever with adding timers or something
            break ;
        }
    }
}

void loop()
{
/***************** UPDATE FUNCTION BLOCKS *****************/
    for( int i = 0 ; i < nBlocks ; i ++ )
    {
        switch( block[i].type )
        {
        case AND: 
            block[i].Q = block[i].IN1 & block[i].IN2 & block[i].IN3 ;
            break ;

        case OR: 
            block[i].Q = block[i].IN1 | block[i].IN2 | block[i].IN3 ;
            break ;

        case M: 
            if(      block[i].IN3 ) block[i].Q = 0 ; // R
            else if( block[i].IN1 ) block[i].Q = 1 ; // S
            break ; 

        case NOT: 
            block[i].Q = !block[i].IN2 ; 
            break ;

        case INPUT: 
            block[i].Q = digitalRead( block[i].pin ) ;
            break ;

        case OUTPUT: 
            digitalWrite( output[i].pin, output[i].IN2 ) ;
            break ;

        // case DEL: for( int i = 0 ; i < n_blocks  ; i ++ )
        //     {
        //         if( block[i].Q != block[i].IN )                                   // if new state changes
        //         {
        //             if( millis() - block[i].oldTime >= block[i].interval )         // keep monitor if interval has expired
        //             {
        //                 block[i].Q = block[i].IN ;                                // if so, adopt the new state
        //             }
        //         }
        //         else
        //         {
        //             block[i].oldTime = millis() ;                                      // if new state does not change, keep setting oldTime
        //         }
        //     }
        //     break ;
        }
    }

/***************** UPDATE LINKS *****************/
    block[1].IN1 = block[2].Q ;
    block[2].IN2 = block[4].Q ;
    block[3].IN3 = block[6].Q ;
    block[1].IN1 = block[1].Q ;
    block[1].IN2 = block[2].Q ;
    block[2].IN1 = block[1].Q ;
    block[2].IN2 = block[2].Q ;
    block[2].IN1 = block[5].Q ;
    block[2].IN3 = block[2].Q ;
} ;

// demo links between blocks

