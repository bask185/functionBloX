class CheckBox
{
    String boxText ;
	int x ;
	int y ;
    int state ;

	CheckBox( int x, int y, String boxText )
	{
		this.x = x ;
		this.y = y ;
		this.boxText = boxText ;
        this.state = 0 ;
	}

	void draw()
	{
        stroke(0);
        if( hoveringOver() ) { fill( 200 ) ;  }
        else                 { fill( 255 ) ;  }
        circle(x, y, 10);                       // draw white/grey circle

		if( state == 1 )
        {
            fill(0) ;
            circle(x, y, 5);                    // draw black check mark
        }

        textSize(15); 
        fill(0) ;
		textAlign(LEFT, CENTER);
		text( boxText, x+15, y ) ;
	}

	boolean hoveringOver()
	{
        if( mouseX < (x+5) && mouseX > (x-5)
        &&  mouseY < (y+5) && mouseY > (y-5) ) return true ;
        return false ;
	}

    void setState(int state)
    {
        this.state = state ;
    }

    int getState()
    {
        return state ;
    }

    String getName()
    {
        return boxText.toLowerCase() ;
    }
} ;