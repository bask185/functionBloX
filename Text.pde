class Text
{
    int x ;
    int y ;
    String description ;

    Text( int x, int y, String description )
    {
        this.x = x ;
        this.y = y ;
        this.description = description ;
    }

    void draw()
    {
        textSize( gridSize / 3 ) ; 
        fill( 0 ) ; 
        textAlign( LEFT, TOP ) ;
        text( description, (x+xOffset)* gridSize, (y+ yOffset)* gridSize );
    }

    void move( int x, int y )
    {
        this.x = x ;
        this.y = y ;
    }

    int getX() { return this.x ; }
    int getY() { return this.y ; }

    void setDescription( String description )
    {
        this.description = description ;
    }

    String getDescription()
    {
        return description ;
    }

    int hoveringOver() // may want to start using the grid locations, this is 'point'less
	{
		if( x == colSpoofed && y == rowSpoofed )
        {
            if( subCol == 0 ) { return 1 ;}
            if( subCol == 1 ) { return 2 ;}
        }
		return 0 ;
	}
} ;