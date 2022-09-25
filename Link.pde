class Link 
{
    final int maxPos = 50 ;

    int isAnalog ;                      // this flag is used to use analog values instead of Q and IN

    int[][] positions = new int[2][maxPos];
    int nPoints = 0 ;

    int Q ;
    int IN1 ;
    int IN2 ;
    int IN3 ;

    int gridSize ;

    int posX ;
    int posY ;
    int subX ;
    int subY ;

    int subRow ;


    Link( int x, int y, int gridSize, int Q, int isAnalog )   // creates the first
    { 
        this.gridSize = gridSize ;
        this.isAnalog = isAnalog ;
        this.Q = Q ;

        IN1 = 0 ;
        IN2 = 0 ;
        IN3 = 0 ;

        subX = 2 ;
        subY = 1 ;

        nPoints = 0 ;

        updatePoint(x, y, subX, subY ) ; // set first 2 coordinates upon creating
        nPoints ++ ;
        updatePoint(x, y, subX, subY ) ;
    }

    void draw()
    {
        for ( int i = 0 ; i < nPoints ; i ++ ) 
        {
            //  x * gridSize + gridSize/6 + subX * gridSize / 3 ;
            //  y * gridSize + gridSize/6 + subY * gridSize / 3 ;

            int xPos = (positions[0][ i ] >>   8 ) ;
            int xSub = (positions[0][ i ] & 0xFF ) ;
            int yPos = (positions[1][ i ] >>   8 ) ;
            int ySub = (positions[1][ i ] & 0xFF ) ;

            int x1 = xPos * gridSize + xSub * gridSize / 3 + gridSize/6;
            int y1 = yPos * gridSize + ySub * gridSize / 3 + gridSize/6;

            xPos = (positions[0][ i+1 ] >>   8 ) ;
            xSub = (positions[0][ i+1 ] & 0xFF ) ;
            yPos = (positions[1][ i+1 ] >>   8 ) ;
            ySub = (positions[1][ i+1 ] & 0xFF ) ;

            int x2 = xPos * gridSize + xSub * gridSize / 3 + gridSize/6 ;
            int y2 = yPos * gridSize + ySub * gridSize / 3 + gridSize/6 ;

            line( x1, y1, x2, y2 ) ;
            circle(x1,y1,3) ;
            circle(x2,y2,3) ;
        }
    }

    void setIn( int subRow, int IN)
    {
        this.subRow = subRow ;
        if( subRow == 0 )  this.IN1 = IN ;
        if( subRow == 1 )  this.IN2 = IN ;
        if( subRow == 2 )  this.IN3 = IN ;
    }

    int getQ()
    {
        return Q ;
    }
    
    int getIn( int idx )
    {
        if( idx == 0 )  return IN1 ;
        if( idx == 1 )  return IN2 ;
        if( idx == 2 )  return IN3 ;
        else return 255 ; // keeps compiler from complaining
    }

    int getSubrow()
    {
        return subRow ;
    }

    void updatePoint( int x, int y, int subX, int subY )
    {
        this.posX = x ;
        this.posY = y ;
        this.subX = subX ;
        this.subY = subY ;

        positions[0][nPoints] = posX << 8 | ( subX & 0x00FF ) ;                 // verified!
        positions[1][nPoints] = posY << 8 | ( subY & 0x00FF ) ;
    }

    void addPoint( )
    {   
        //updatePoint( column, row, subX, subY ) ;
        nPoints ++ ;
    }

    void storePoint()
    {
        if( nPoints < maxPos - 1 ) nPoints ++ ;
        else println("array link full");
    }

    int getNlinks()  { return nPoints ; }
    int getPosX( int index ) { return positions[0][index] >> 8 ;   }
    int getPosY( int index ) { return positions[1][index] >> 8 ;   }
    int getSubX( int index ) { return positions[0][index] & 0xFF ; }
    int getSubY( int index ) { return positions[1][index] & 0xFF ; }
 

    boolean removePoint()
    {
        if( nPoints >  0 ) nPoints -- ;

        println(nPoints) ;

        if( nPoints == 0 ) { return  true ; }
        else                 return false ;
    }

    int isAnalogIO() { return isAnalog ; }
}
