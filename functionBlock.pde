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
        fill(245);
        if( type < 6 ) // if not input or output
        {
            rect( xPos * gridSize + (gridSize/5), yPos * gridSize + 1, 3*gridSize/5, gridSize - 2 ) ; // main box
        }
        else if( type == 6 )
        {
            stroke(245);
            rect( xPos * gridSize, yPos * gridSize +(gridSize/4), gridSize/2, gridSize/2 ) ; // input
            triangle(xPos * gridSize + (gridSize/2),   yPos * gridSize +(gridSize/4),
                     xPos * gridSize +  gridSize,      yPos * gridSize +(gridSize/2),
                     xPos * gridSize + (gridSize/2),   yPos * gridSize + 3*gridSize/4) ;
        }
        else if( type == 7)
        {
            stroke(245);
            rect( xPos * gridSize +(gridSize/2), yPos * gridSize+(gridSize/4), gridSize/2, gridSize/2 ) ; // output
            triangle(xPos * gridSize + (gridSize/2),   yPos * gridSize + (gridSize/4),
                     xPos * gridSize,                  yPos * gridSize + (gridSize/2),
                     xPos * gridSize + (gridSize/2),   yPos * gridSize + 3*gridSize/4) ;
            
        }
        stroke(0);
        fill(255);

        byte box = 0 ;
        String txt = "" ;

        switch( type )
        {                         // in1, in2, in3,
            case 1: txt =  "AND" ;  box = 0x0F ; break ;
            case 2: txt =   "OR" ;  box = 0x0F ; break ;
            case 3: txt =   " M" ;  box = 0x0D ; break ;
            case 4: txt ="DELAY" ;  box = 0x0A ; break ;
            case 5: txt =  "NOT" ;  box = 0x0A ; break ; // text replaced by clock symbol
            case 6: txt =   "IN " + pin;  box = 0x08 ; break ;
            case 7: txt =  "OUT " + pin;  box = 0x02 ; break ;
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

        textSize( gridSize / 5 ) ; 
        
        int x = xPos * gridSize + gridSize/2 ;
        int y = yPos * gridSize + gridSize/2 ;

        text( txt, x , y ) ;
        textSize( gridSize / 5 ) ; 
        if( type == 3 ) text( "S\n\nR", x-(gridSize/5) , y ) ; // draw S and R for memory
        if( type == 4 )
        {
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

    void setGridSize( int gridSize )
    {
        this.gridSize = gridSize ;
    }
    
    void setPin( int pin ) { this.pin = pin ; }
    int  getXpos() { return xPos ; }
    int  getYpos() { return yPos ; }
    int  getType() { return type ; }
    int  getPin()  { return pin  ; }
}