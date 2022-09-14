public class FunctionBlock
{
    int xPos ;
    int yPos ;
    int type ;
    int gridSize ;

    int IN1 ;
    int IN2 ;
    int IN3 ;
    int Q   ;
    int index ;

    FunctionBlock(int xPos, int yPos, int type, int gridSize, int index )
    {
        this.xPos       = xPos ;
        this.yPos       = yPos ;
        this.type       = type ;
        this.gridSize   = gridSize ;
        this.index      = index ;
    }

    void draw()
    {
        textAlign( CENTER, CENTER ) ;
        fill(245);
        rect( xPos * gridSize + (gridSize/5), yPos * gridSize + 1, 3*gridSize/5, gridSize - 2 ) ; // main box
        fill(255);

        byte box = 0 ;
        String txt = "" ;

        switch( type )
        {                         // in1, in2, in3,
            case 1: txt =   "&" ;  box = 0b111 ; break ;
            case 2: txt =  ">1" ;  box = 0b111 ; break ;
            case 3: txt =  " M" ;  box = 0b101 ; break ;
            case 4: txt =   "!" ;  box = 0b010 ; break ; // text replaced by clock symbol
            case 5: txt =   "1" ;  box = 0b010 ; break ;
        }

        int x1 = xPos * gridSize ;
        int x2 = xPos * gridSize + gridSize/5 ;
        int y1 = yPos * gridSize + gridSize/6 + 0 * gridSize / 3 ;
        int y2 = yPos * gridSize + gridSize/6 + 1 * gridSize / 3 ;
        int y3 = yPos * gridSize + gridSize/6 + 2 * gridSize / 3 ;

        if( (box & 0b0001) > 0 ) line(x1, y1, x2, y1) ; //rect( xPos * gridSize,                yPos * gridSize +   gridSize/5, gridSize/5, gridSize/5 ) ; // top left
        if( (box & 0b0010) > 0 ) line(x1, y2, x2, y2) ; //rect( xPos * gridSize,                yPos * gridSize + 3*gridSize/5, gridSize/5, gridSize/5 ) ; // bottom left
        if( (box & 0b0100) > 0 ) line(x1, y3, x2, y3) ; //rect( xPos * gridSize + 4*gridSize/5, yPos * gridSize +   gridSize/5, gridSize/5, gridSize/5 ) ; // top right
        
        x1 = xPos * gridSize + gridSize ;
        x2 = xPos * gridSize + gridSize - gridSize/5 ;
        line(x1, y2, x2, y2) ;                          // line of Q
        //if( type == 5 )          line(x1, y1, x2, y1) ; //ellipse( xPos * gridSize + 7*gridSize/8, yPos * gridSize +   gridSize/3, gridSize/5, gridSize/5 ) ; // ellipse for not
        fill(0);

        textSize( gridSize / 4 ) ; 
        
       
        
        int x = xPos * gridSize + gridSize/2 ;
        int y = yPos * gridSize + gridSize/2 ;

        text( txt, x , y ) ;
        textSize( gridSize / 5 ) ; 
        if( type == 3 ) text( "S\nR", x-(gridSize/5) , y ) ; // draw S and R for memory
        if( type == 4 )
        {
            fill(255);
            
            //marc( gridSize * xPos + gridSize/2, gridSize * yPos + gridSize/4, gridSize/3, gridSize/3, -HALF_PI, PI ); // draws partial circle for delay symbol
            
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
    
    int  getXpos() { return xPos ; }
    int  getYpos() { return yPos ; }
    int  getType() { return type ; }
    int  getIndex() { return index ; }
}