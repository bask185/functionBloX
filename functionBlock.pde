public class FunctionBlock
{
    int xPos ;
    int yPos ;
    int type ;
    int gridSize ;
    int index ;

    int IN1 ;
    int IN2 ;
    int IN3 ;
    int Q ;
    int pin ;
    int delayTime ;
    int constVal ;

    char a, b, c ;

    String serialText ;

    int in1, in2, out1, out2 ;

    int isAnalog ;

    FunctionBlock(int xPos, int yPos, int type, int gridSize )
    {
        this.xPos       = xPos ;
        this.yPos       = yPos ;
        this.type       = type ;
        this.gridSize   = gridSize ;
        isAnalog        = 0 ;

        if( type == ANA_IN || type == ANA_OUT || type == SERVO
        ||  type ==    MAP || type == COMP    || type == DELAY
        ||  type ==  CONSTANT ) isAnalog = 1 ;
    }

    void draw()
    {
        int x1,x2,x3,x4,x5,x6 ;
        int y1,y2,y3,y4,y5,y6 ;

        textAlign( CENTER, CENTER ) ;
        fill(fbColor); //dark red boxes

        switch( type )
        {
        case     AND:
        case      OR:
        case       M:
        case     DELAY:
        case     NOT:
        case      JK:
        case  ANA_IN:
        case ANA_OUT:
        case  OUTPUT:
        case   INPUT:
        case   SERVO:
        case     MAP:
        case SER_IN:
        case SER_OUT:
        case CONSTANT:
            rect( 
                xPos * gridSize + (gridSize/5), 
                yPos * gridSize + 1, 
                3*gridSize/5, 
                gridSize - 2 ) ; // main box
            break ;

        case COMP: // comperator TRIANGLE SYMBOL
            x1 = xPos * gridSize + (gridSize/5) ;
            y1 = yPos * gridSize ;
            x2 = x1 ;
            y2 = y1 + gridSize ;
            x3 = x1 + 3*gridSize/5 ;
            y3 = y1 + (y2 - y1) / 2 ;
            triangle(x1,y1,x2,y2,x3,y3) ;
            break ;

        case PULSE: // CICLE PLUS PULSE SYMBOL
            ellipse( xPos * gridSize + (gridSize/2), yPos * gridSize + (gridSize/2), 3*gridSize/5, 3*gridSize/5 ) ; // perhaps replace by image?
            x1 = xPos*gridSize + 3*gridSize/9;
            y1 = yPos*gridSize+ gridSize/2;
            x2 = xPos*gridSize + 4*gridSize/9;
            y2 = y1 ;
            x3 = x2 ;
            y3 = yPos*gridSize + 3*gridSize/9;
            x4 = xPos*gridSize + 5*gridSize/9;
            y4 = y3 ;
            x5 = x4 ;
            y5 = y1 ;
            x6 = xPos*gridSize + 6*gridSize/9;
            y6 = y1 ;
            line(x1,y1,x2,y2);
            line(x2,y2,x3,y3);
            line(x3,y3,x4,y4);
            line(x4,y4,x5,y5);
            line(x5,y5,x6,y6);
            break ;
        }
        stroke(0);

        byte box = 0 ;
        String txt = "" ;
        try
        {
            a = serialText.charAt(0) ;
            b = serialText.charAt(1) ;
            c = serialText.charAt(2) ;
        }
        catch( NullPointerException e ) {}
        catch( StringIndexOutOfBoundsException e) {}

        // draw the input and output connection lines and make up the text inside the block
        switch( type )
        {                                       // box bits: Q, in1, in2, in3,
            case      AND: txt =  "AND" ;                     box = 0x0F ; break ;
            case       OR: txt =   "OR" ;                     box = 0x0F ; break ;
            case      DELAY: txt ="DELAY\r\n\r\n" + delayTime;box = 0x0A ; break ;
            case      NOT: txt =  "NOT" ;                     box = 0x0A ; break ; // text replaced by clock symbol
            case    INPUT: txt = "INPUT\r\nD" + pin;     box = 0x08 ; break ;
            case   OUTPUT: txt ="OUTPUT\r\nD" + pin;     box = 0x02 ; break ;
            case       JK: txt =  "J    \r\nK    \r\nCLK";    box = 0x0F ; break ;
            case        M: txt = "S      \r\nM\r\nR      ";   box = 0x0D ; break ;
            case    PULSE: txt= "\r\n" +  delayTime;          box = 0x08 ; break ;
            case   ANA_IN: txt= "ADC\r\n\r\nA" + pin;         box = 0x08 ; break ;
            case  ANA_OUT: txt= "PWM\r\n\r\nD" + pin;         box = 0x02 ; break ;
            case    SERVO: txt= "SERVO\r\n"  + pin;           box = 0x02 ; break ;
            case   SER_IN: txt= "MESS\r\nIN\r\n"+a+b+c;       box = 0x08 ; break ;
            case  SER_OUT: txt= "MESS\r\nOUT\r\n"+a+b+c ;     box = 0x02 ; break ;
            case      MAP: txt= in1 + "  " + in2 + "\r\nMAP\r\n"
                             + out1 + "  " + out2 ;           box = 0x0A ; break ;
            case     COMP: txt = "+      \r\n-      ";        box = 0x0D ; break ;
            case CONSTANT: txt = "CONST\r\n\r\n"+ delayTime;  box = 0x08 ; break ;
        }

        x1 = xPos * gridSize + gridSize/8 ;
        x2 = xPos * gridSize + gridSize/5 ;
        y1 = yPos * gridSize + gridSize/6 + 0 * gridSize / 3 ;
        y2 = yPos * gridSize + gridSize/6 + 1 * gridSize / 3 ;
        y3 = yPos * gridSize + gridSize/6 + 2 * gridSize / 3 ;

        if( (box & 0x01) > 0 ) line(x1, y1, x2, y1) ; //rect( xPos * gridSize,                yPos * gridSize +   gridSize/5, gridSize/5, gridSize/5 ) ; // top left
        if( (box & 0x02) > 0 ) line(x1, y2, x2, y2) ; //rect( xPos * gridSize,                yPos * gridSize + 3*gridSize/5, gridSize/5, gridSize/5 ) ; // bottom left
        if( (box & 0x04) > 0 ) line(x1, y3, x2, y3) ; //rect( xPos * gridSize + 4*gridSize/5, yPos * gridSize +   gridSize/5, gridSize/5, gridSize/5 ) ; // top right
        
        x1 = xPos * gridSize + 4*gridSize/5 ;
        x2 = xPos * gridSize + 8*gridSize/9 ;
        if( (box & 0x08) > 0 )//if( type == 5 )          line(x1, y1, x2, y1) ; //ellipse( xPos * gridSize + 7*gridSize/8, yPos * gridSize +   gridSize/3, gridSize/5, gridSize/5 ) ; // ellipse for not
        line(x1, y2, x2, y2) ;                          // line of Q
        fill(textColor);

        
        int x = xPos * gridSize + gridSize/2 ;
        int y = yPos * gridSize + gridSize/2 ;

        textSize( gridSize / 6 ) ; 
        text( txt, x , y ) ;
        textSize( gridSize / 5 ) ; 
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

    
    int isAnalog() { return isAnalog ; }

    void setIndex( int index ) { this.index = index ; }
    int  getIndex() { return index ; }
    int  getType()  { return  type ; }

    void setConst( int constVal ) { this.constVal = constVal ; }
    int  getConst() { return constVal ; }

    void setIn1(  int x) { this.in1  = x ; }
    void setIn2(  int x) { this.in2  = x ; }
    void setOut1( int x) { this.out1 = x ; }
    void setOut2( int x) { this.out2 = x ; }
    int  getIn1()  { return  in1 ; }
    int  getIn2()  { return  in2 ; }
    int  getOut1() { return out1 ; }
    int  getOut2() { return out2 ; }

    void setText(String serialText) { this.serialText = serialText ; }
    String getText() { return serialText ; }}