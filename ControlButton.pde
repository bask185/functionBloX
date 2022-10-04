public class ControlButton
{
    String boxText ;
	int x ;
	int y ;

	ControlButton( int x, int y, String boxText )
	{
		this.x = x ;
		this.y = y ;
		this.boxText = boxText ;
	}

	boolean draw()
	{
		textSize(15); 
		fill(fbColor);
		rect(x,y,100,50);
		fill(0);
		textAlign(CENTER, CENTER);
		text( boxText, x+50, y+25 ) ;

		if( mouseX > x && mouseX < x+100
		&&  mouseY > y && mouseY < y+50 ) return true ;
		else return false ;
	}
}