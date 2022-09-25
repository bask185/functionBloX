public class FunctionBlock
{
    int xPos ;
    int yPos ;
    int type ;
    int gridSize ;

    int IN1 ;
    int IN2 ;
    int IN3 ;
    int Q ;
    int pin ;
    int delayTime ;

    FunctionBlock(int xPos, int yPos, int type, int gridSize )
    {
        this.xPos       = xPos ;
        this.yPos       = yPos ;
        this.type       = type ;
        this.gridSize   = gridSize ;
    }

    void draw()
    {
        textAlign( CENTER, CENTER ) ;
        fill(230);

        switch( type )
        {
        case     AND:
        case      OR:
        case       M:
        case     DEL:
        case     NOT:
        case      JK:
        case  ANA_IN:
        case ANA_OUT:
            rect( xPos * gridSize + (gridSize/5), yPos * gridSize + 1, 3*gridSize/5, gridSize - 2 ) ; // main box
            break ;

        case  INPUT:
            stroke(245);
            rect( xPos * gridSize, yPos * gridSize +(gridSize/4), gridSize/2, gridSize/2 ) ; // input
            triangle(xPos * gridSize + (gridSize/2),   yPos * gridSize +(gridSize/4),
                     xPos * gridSize +  gridSize,      yPos * gridSize +(gridSize/2),
                     xPos * gridSize + (gridSize/2),   yPos * gridSize + 3*gridSize/4) ;
            break ;
                     
        case OUTPUT:
            stroke(245);
            rect( xPos * gridSize +(gridSize/2), yPos * gridSize+(gridSize/4), gridSize/2, gridSize/2 ) ; // output
            triangle(xPos * gridSize + (gridSize/2),   yPos * gridSize + (gridSize/4),
                     xPos * gridSize,                  yPos * gridSize + (gridSize/2),
                     xPos * gridSize + (gridSize/2),   yPos * gridSize + 3*gridSize/4) ;
            break ;

        case PULSE:  
            ellipse( xPos * gridSize + (gridSize/2), yPos * gridSize + (gridSize/2), 3*gridSize/5, 3*gridSize/5 ) ;
            int x1 = xPos*gridSize + 3*gridSize/9;
            int y1 = yPos*gridSize+ gridSize/2;
            int x2 = xPos*gridSize + 4*gridSize/9;
            int y2 = y1 ;
            int x3 = x2 ;
            int y3 = yPos*gridSize + 3*gridSize/9;
            int x4 = xPos*gridSize + 5*gridSize/9;
            int y4 = y3 ;
            int x5 = x4 ;
            int y5 = y1 ;
            int x6 = xPos*gridSize + 6*gridSize/9;
            int y6 = y1 ;
            line(x1,y1,x2,y2);
            line(x2,y2,x3,y3);
            line(x3,y3,x4,y4);
            line(x4,y4,x5,y5);
            line(x5,y5,x6,y6);
            break ;
        }
        stroke(0);
        fill(255);

        byte box = 0 ;
        String txt = "" ;

        // draw the input and output connection lines
        switch( type )
        {                                       // box bits: Q, in1, in2, in3,
            case     AND: txt =  "AND" ;                     box = 0x0F ; break ;
            case      OR: txt =   "OR" ;                     box = 0x0F ; break ;
            case       M: txt =   " M" ;                     box = 0x0D ; break ;
            case     DEL: txt ="DELAY\r\n\r\n" + delayTime ; box = 0x0A ; break ;
            case     NOT: txt =  "NOT" ;                     box = 0x0A ; break ; // text replaced by clock symbol
            case   INPUT: txt =   "IN\r\n" + pin;            box = 0x08 ; break ;
            case  OUTPUT: txt =  "OUT\r\n" + pin;            box = 0x02 ; break ;
            case      JK: txt =  "J    \r\nK    \r\nCLK";    box = 0x0F ; break ;
            case   PULSE: txt= "\r\n" +  delayTime;          box = 0x08 ; break ;
            case  ANA_IN: txt= "ADC\r\n\r\nA" + pin;         box = 0x08 ; break ;
            case ANA_OUT: txt= "PWM\r\n\r\n~" + pin;         box = 0x02 ; break ;
        }

        int x1 = xPos * gridSize ;
        int x2 = xPos * gridSize + gridSize/5 ;
        int y1 = yPos * gridSize + gridSize/6 + 0 * gridSize / 3 ;
        int y2 = yPos * gridSize + gridSize/6 + 1 * gridSize / 3 ;
        int y3 = yPos * gridSize + gridSize/6 + 2 * gridSize / 3 ;

        if( (box & 0x01) > 0 ) line(x1, y1, x2, y1) ; //rect( xPos * gridSize,                yPos * gridSize +   gridSize/5, gridSize/5, gridSize/5 ) ; // top left
        if( (box & 0x02) > 0 ) line(x1, y2, x2, y2) ; //rect( xPos * gridSize,                yPos * gridSize + 3*gridSize/5, gridSize/5, gridSize/5 ) ; // bottom left
        if( (box & 0x04) > 0 ) line(x1, y3, x2, y3) ; //rect( xPos * gridSize + 4*gridSize/5, yPos * gridSize +   gridSize/5, gridSize/5, gridSize/5 ) ; // top right
        
        x1 = xPos * gridSize + gridSize ;
        x2 = xPos * gridSize + gridSize - gridSize/5 ;
        if( (box & 0x08) > 0 )//if( type == 5 )          line(x1, y1, x2, y1) ; //ellipse( xPos * gridSize + 7*gridSize/8, yPos * gridSize +   gridSize/3, gridSize/5, gridSize/5 ) ; // ellipse for not
        line(x1, y2, x2, y2) ;                          // line of Q
        fill(0);

        textSize( gridSize / 6 ) ; 
        
        int x = xPos * gridSize + gridSize/2 ;
        int y = yPos * gridSize + gridSize/2 ;

        text( txt, x , y ) ;
        textSize( gridSize / 5 ) ; 
        if( type ==   M ) text( "S\n\nR", x-(gridSize/5) , y ) ; // draw S and R for memory
        if( type == DEL ) // delay
        {
            // ... is this not for that small diagonal line for the NOT gates?
            fill(255);            
            x1 = xPos * gridSize + gridSize / 2 ;   
            y1 = yPos * gridSize + gridSize / 2 ;
            y2 = yPos * gridSize ;
            line(x1, y2, x1, y2) ;
            fill(0);
        }
    }

    void setPos( int xPos, int yPos )
    {
        this.xPos = xPos ;
        this.yPos = yPos ;
    }
    int  getXpos() { return xPos ; }
    int  getYpos() { return yPos ; }

    void setGridSize( int gridSize )
    {
        this.gridSize = gridSize ;
    }
    
    void setPin( int pin ) { this.pin = pin ; }
    int  getPin()  { return pin  ; }

    void setDelay( int delayTime ) { this.delayTime = delayTime ; }
    int  getDelay( ) { return delayTime ; }

    int  getType() { return type ; }
}