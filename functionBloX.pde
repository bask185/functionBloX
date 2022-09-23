/* THINGS TODO
V finalize part to create, move and delete all items, re-use things from NX GUI (DONER)
V create link if we are hovering about a Q output..
V change boxes to stripes, make extra stripe for not. And make 3 stripes per item
V create all GPIO items, inputs, outputs, ~~~pwm out, analog in~~~.
X make onscreen keypad to click on numbers so one may enter a number for an input for instance
V create the arduino framework
V make 3 inputs for and and or gates
V beacon off the X and Y limits to exlude the right and bottom side (DONER)
V auto set modes, depending on where one clicks. I no longer want to use the kayboard. (DONER)
V remove subclasses and change the functionBlock class to contain type variable.. (DONER, seems to work)
V add a dynamic message box which tells you what LMB and RMB does at any time
V organize update cursor with functions.
V try to remove the locked variable, may unneeded <== was useless
V organize all texts
V use keyboard to enter numbers, also make sure that the current index does not change
V need some interlocking while creating and moving blocks. It happens alot that
we get index out of bounds error with the first block. 
You can draw 2 blocks on eachother which is really annoying
sometimes while making and dragging a new block, you are removing the previous block.
It seems that the index lags behind..
V you can delete an item while creating a line
V pressing LMB on a block while adding link points, causes the mode to switch to moving
V you can 'finish' a link on every row, as long as the column is ok...
I think over over FB is always true?
V entering a number works, but as soon as you touch a new function block
the number is overwritten. It seems that all blocks share the pin number -_-
- create special items like servo motors, blinking lights (auto toggling IO)
- make variable gridsize workable
- store and load layout, add buttons.
- add small sphere to mouse if there is anything to click. perhaps half green and half red to indicate which buttons can be pressed
- make small nodes along link nodes, so you can see when lines just simply cross
- may need to refactor to separate classes so it becomes easier to add the new analog items
V ID of Function blocks also need to be stored for the input and output blocks
- add method to update all links' Qs and INs for when a FB is removed or replaced. Currently links will point to the old index
  and this may or may not be correct...

EXTRA
- make comperator for usage with analog input
- make separate arrays for AND, NOR and MEMORIES. , unsure if actually needed, it may help with generating organized source code.
- also add NAND or NOR gates or implement inverted outputs !Q
- let textSize change appropiate with gridSize for all function blox
- add panning for larger layouts

BACKLOG
- move node of a line by dragging it with LMB
- for the analog stuff, make a map block

CURRENT WORK:
THE CORE FUNCTIONS SHOULD WORK. IT MUST BE TESTED WITH REAL INPUTS AND OUTPUTS. DELAYS are not yet working
- making delay to work!
(if needed, refactor code to sub classes again

add pinnumber links for all input and outputs to the arduino program

3 events:
mouse pressed ==> create line object and store initial X/Y coordinates. Inc point index
mouse drag    ==> update the current element with new X/Y coordinates
mouse release ==> increment the index counter
mousewheel    ==> alter grid size

*/

PrintWriter     file ;
PrintWriter     output;
BufferedReader  input;
PImage          mouse;

String text1 = "" ;
String text2 = "" ;

ArrayList <FunctionBlock> blocks = new ArrayList() ;
ArrayList <Link>          links  = new ArrayList() ;

final int   idle = 0 ;
final int   movingItem = 1 ;
final int   deletingItem = 2 ;
final int   makingLinks  = 3 ;
final int   addingLinePoints = 4 ;
final int   settingNumber = 5 ;

int         gridSize = 60 ;

final int    AND = 1 ;
final int     OR = 2 ;
final int      M = 3 ;
final int    DEL = 4 ;
final int    NOT = 5 ;
final int  INPUT = 6 ;
final int OUTPUT = 7 ;


// digital input
// digital output
// potentiometer
// PWM
// SERVO
// occupanceDetector
// DCC accessory article,
// DCC loco function

int         col ;
int         row ;
int         subCol ;
int         subRow ;
int         nItems ;
boolean     locked ;
int         index ;
int         mode = idle ;
int         linkIndex = 0 ;
int         foundLinkIndex ;
int         currentType ;
int         pinNumber;

boolean     hoverOverFB ;
boolean     hoverOverPoint ;
boolean     blockMiddle ;

FunctionBlock or1 ;
FunctionBlock and1 ;
FunctionBlock sr1 ;
FunctionBlock delay1 ;
FunctionBlock not1 ;
FunctionBlock inp1 ;
FunctionBlock outp1 ;


void setup()
{
   
    //fullScreen() ;
    loadLayout() ;
    size(displayWidth, displayHeight) ;
    textSize( 20 );
    background(255) ;
    
    and1    = new FunctionBlock((width-gridSize)/gridSize, 0, AND, gridSize ) ;
    or1     = new FunctionBlock((width-gridSize)/gridSize, 1,  OR, gridSize ) ;
    sr1     = new FunctionBlock((width-gridSize)/gridSize, 2,   M, gridSize ) ;
    delay1  = new FunctionBlock((width-gridSize)/gridSize, 3, DEL, gridSize ) ;
    not1    = new FunctionBlock((width-gridSize)/gridSize, 4, NOT, gridSize ) ;
    inp1    = new FunctionBlock((width-gridSize)/gridSize, 5, INPUT, gridSize ) ;
    outp1   = new FunctionBlock((width-gridSize)/gridSize, 6, OUTPUT, gridSize ) ;
}

void draw()
{
    drawBackground() ;
    checkFunctionBlocks() ;
    checkLinePoints() ;
    printTexts() ;
    updateCursor() ;
    drawBlocks() ;
    drawLinks() ;
}



void leftMousePress()
{
    if( mode == settingNumber ) return ;                                        // as long as a number is set, LMB nor RMB must do anything

    if((mouseX > (width-gridSize)) && mode == idle )
    {
        mode = movingItem ;         
        currentType = row + 1 ;
        pinNumber = 0 ;

        blocks.add( new FunctionBlock(( width- 2*gridSize) / gridSize, row, currentType, gridSize )) ;

        index = blocks.size() - 1 ;
        return ;
    }

    else if( mode == idle ) for (int i = 0; i < blocks.size(); i++)
    { 
        FunctionBlock block = blocks.get(i);

        if( col == block.getXpos() &&  row == block.getYpos() && blockMiddle == true )
        {
            mode = movingItem ;
            index = i;
            return ;
        }
        //else index = 0 ;
    }
    
    // CREATE LINK
    if(  mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true )  // if not doing anything and we click on a connection node, create a line.
    {
        mode = addingLinePoints ;
       
        links.add( new Link( col, row, gridSize, index ) ) ;
        Link link = links.get( linkIndex ) ;
        link.updatePoint( col, row, subCol, subRow  ) ;
    }

    // FINISH LINK
    else if( mode == addingLinePoints && subCol == 0 && hoverOverFB == true )
    {
        mode = idle ;
        
        Link link = links.get( linkIndex ) ;
        link.setIn( subRow, index ) ;
        linkIndex ++ ;
    }

    // ADD NODE TO LINK
    else if( mode == addingLinePoints )
    {
        Link link = links.get( linkIndex ) ;
        link.addPoint( ) ;
        link.updatePoint( col, row, subCol, subRow  ) ;
    }
}

void rightMousePress()
{
    if( mode == settingNumber ) return ;                                        // as long as a number is set, LMB nor RMB must do anything

    /* if hover about a FB, delete it */
    if( mode == idle 
    && blocks.size() > 0 
    &&  index < blocks.size() 
    && hoverOverFB == true
    && blockMiddle == true )
    {
        blocks.remove(index);		// DELETE THE OBJECT
        hoverOverFB = false ;
    }

    // REMOVE PREVIOUS ADDED NODE OR ENTIRE LINK
    else if( mode == addingLinePoints )
    {
        Link link =links.get( linkIndex ) ;
        if( link.removePoint( ) )
        {
            mode = idle ;
            links.remove(linkIndex) ;
        }
        else
        {
            link.updatePoint( col, row, subCol, subRow  ) ;
        }
    }

    // REMOVE LINK
    else if( hoverOverPoint )
    {
        println("foundLinkIndex: " + foundLinkIndex) ;
        links.remove( foundLinkIndex ) ;
        linkIndex -- ;
    }
}


void mousePressed()
{	
    if( mouseButton ==  LEFT )  leftMousePress() ;
    if( mouseButton == RIGHT ) rightMousePress() ;
}

void mouseDragged()
{
    if( mode == movingItem )
    {
        FunctionBlock block = blocks.get(index);
        block.setPos(col,row);
    } 
}

void mouseMoved()
{
    if( mode == addingLinePoints )
    {
        Link link = links.get( linkIndex ) ;
        link.updatePoint( col, row, subCol, subRow  ) ;
    }
}

void mouseReleased()
{
    if( mode == movingItem )
    { 
        if( currentType == INPUT || currentType == OUTPUT ) mode = settingNumber ;
        else mode = idle ; 
    }
}

/***   <-- use this function to adjust gridsize icm 
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  println(e);
}
-*********/


void drawBackground()
{
    background(230) ;
    fill(255) ;
    rect(0,0,(width - gridSize) - 2 , (height - gridSize) - 2 ) ;

    textAlign(CENTER,CENTER);

    and1.draw() ;       // draw default items
    or1.draw() ;
    sr1.draw() ;
    delay1.draw() ;
    not1.draw() ;
    inp1.draw() ;
    outp1.draw() ;
}

void drawLinks()
{
    for (int i = 0; i < links.size(); i++) 
    {
        Link link = links.get(i) ;
        link.draw() ;

    }
}

void drawBlocks()
{
    for (int i = 0; i < blocks.size(); i++)          // loop through all blocks
    {
        FunctionBlock block = blocks.get(i) ;        // declare a local function block and call draw()
        block.setGridSize( gridSize ) ;
        block.draw() ;
    }
}

void checkFunctionBlocks()
{
    if( mode == movingItem ) return ;

    blockMiddle = false ;
    for (int i = 0; i < blocks.size(); i++)                                     // loop over all function blocks, sets index according and sets or clears 'hoverOverFB'
    { 
        hoverOverFB = false ;

        FunctionBlock block = blocks.get(i);
        
        if( col == block.getXpos() 
        &&  row == block.getYpos() )
        {
            // TODO
            // boolean     hoverOverPoint ;

            hoverOverFB = true ;

            if( subCol == 1 && subRow == 1 ) blockMiddle =  true ;
            
            index = i ;
            return ;
        }
    }
}

// determens if the cursor hovers above 
void checkLinePoints()
{
    if( mode != idle ) return ;

    hoverOverPoint = false ;
    for( foundLinkIndex = 0 ; foundLinkIndex < links.size() ; foundLinkIndex++ )
    {
        Link link = links.get(foundLinkIndex) ;
        
        for( int j = 0 ; j < link.getNlinks() ; j++ )
        {
            if( link.getPosX( j ) == col      //text("col: true",10,230);
            &&  link.getPosY( j ) == row      //text("row: true",10,250);
            &&  link.getSubX( j ) == subCol   //text("subCol: true" ,10,270); 
            &&  link.getSubY( j ) == subRow ) //text("subRow: true" ,10,290);
            {   
                hoverOverPoint = true ;
                return ;
            }
        }
    }
}

void updateCursor()
{

    col = mouseX / gridSize ;
    int max_col = (width - 2*gridSize) / gridSize ;
    col = constrain( col, 0, max_col ) ;

    row =    mouseY / gridSize ;
    int max_row = (height - 2*gridSize ) / gridSize ;
    row = constrain( row, 0, max_row ) ;

    if( mode != movingItem )
    {
        subCol = mouseX / (gridSize/3) % 3 ;
        subRow = mouseY / (gridSize/3) % 3 ;
    }  

    textAlign(LEFT,TOP);
    textSize(20);    
    text("X: " + col,10,50);                                                         // row and col on screen.
    text("Y: " + row,10,70);
    //if(hoverOverFB==true)text("ITEM TRUE",10,90);
    text("index: "+ index,10,90);
    text("mode " + mode,10,110);
    text("subCol " + subCol,10,130);
    text("subRow " + subRow,10,150);
    if(hoverOverPoint == true ) text("line detected ",10,190);    
}

void printTexts()
{
    try { FunctionBlock block = blocks.get(index); }
    catch (IndexOutOfBoundsException e) {}

    if(mouseX > (width-gridSize)  && mode == idle ) // seems to work very well
    {
        text1 = "New function block" ;
        text2 = "" ;
        mouse = loadImage("images/mouse2.png") ;
    }
    else if(  mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true )
    {
        text1 = "create link" ;
        text2 = "delete link" ;
        mouse = loadImage("images/mouse3.png") ;
    }
    else if( mode == idle && hoverOverFB  && blockMiddle == true )
    {
        text1 = "move item" ;
        text2 = "delete item" ;
        mouse = loadImage("images/mouse3.png") ;
    }
    else if( mode == idle && hoverOverPoint )
    {
        text1 = "move node" ;
        text2 = "delete link" ;
        mouse = loadImage("images/mouse3.png") ;
    }
    else if( mode == addingLinePoints && subCol == 0 && hoverOverFB == true )
    {
        text1 = "finish point" ;
        text2 = "" ;
        mouse = loadImage("images/mouse2.png") ;
    }
    else if( mode == addingLinePoints )
    {
        text1 = "add point" ;
        text2 = "remove last point" ;
        mouse = loadImage("images/mouse3.png") ;
    }
    else if( mode == movingItem)
    {
        text1 = "Moving function block" ;
        text2 = "" ;
        mouse = loadImage("images/mouse2.png") ;
    }
    else if( mode == settingNumber)
    {
        text1 = "SET PIN NUMBER, HIT <ENTER> WHEN READY" ;
        text2 = "" ;
        mouse = loadImage("images/mouse1.png") ;
    }
    else
    {
        text1 = "" ;
        text2 = "" ;
        mouse = loadImage("images/mouse1.png") ;
    }
    image(mouse, width/2-gridSize, gridSize/5,gridSize,gridSize);
    textSize(gridSize/2);  
    textAlign(RIGHT,TOP);
    text( text1,  width/2 - gridSize, 0 ) ;
    textAlign(LEFT,TOP);
    text( text2, width/2, 0 ) ;
    textAlign(CENTER,CENTER);
}

// ASSEMBLE ARDUINO PROGRAM.
int makeNumber(int _number, int lowerLimit, int upperLimit )
{
    //if( (key >= '0' && key <= '9') || keyCode == BACKSPACE || keyCode == LEFT || keyCode == RIGHT )
    //{
         if( keyCode ==  LEFT      ) { _number -- ;             }
    else if( keyCode == RIGHT      ) { _number ++ ;             }
    else if( _number == upperLimit ) { _number = ( key-'0' ) ;  }
    else if( keyCode == BACKSPACE  ) { _number /= 10;           }
    else if( key >= '0' && key <= '9') 
    {
        _number *= 10;
        _number += ( key-'0' );
    }

    _number = constrain(_number,lowerLimit,upperLimit);   
    //println(_number);    
    return _number;
}

void keyPressed()
{
    // PRINT LINKS FOR DEBUGGING
    if (key == ESC) 
    {
        println("escape pressed");
        key = 0 ;
    }
    if( key == 'd')
    {
        for( int  i = 0 ; i < links.size() ; i ++ )
        {
            Link link = links.get(i) ;
            int Q = link.getQ() ;
            int IN1 = link.getIn(0) ;
            int IN2 = link.getIn(1) ;
            int IN3 = link.getIn(2) ;
            println("\r\nQ: " +Q) ;
            println("IN1: "  + IN1 ) ;
            println("IN2: "  + IN2 ) ;
            println("IN3: "  + IN3 ) ;
        }
    }
    
    if( mode == settingNumber )
    {
        if( keyCode == ENTER )
        {
            mode = idle ;
            return ;
        }
        else
        {
            pinNumber = makeNumber( pinNumber, 0, 31) ;

            FunctionBlock block = blocks.get( index ) ;
            block.setPin( pinNumber ) ;
        }
    }
    if( key == 's') saveLayout() ;

    if( key == 't' )
    {
        for( int i = 0 ; i < blocks.size() ; i ++ )
        {
            FunctionBlock block = blocks.get( i ) ;
            int number = block.getPin() ;
            println(number) ;
        }
    }
    if( key == 'p' )
    {
        assembleProgram() ;
    }
}

void saveLayout()
{
    println("LAYOUT SAVED");

    output = createWriter("program.csv");

    output.println(blocks.size());          // the amount of elements is saved first, this is used for the loading
    for (int i = 0; i < blocks.size(); i++ )
    {
        FunctionBlock block = blocks.get(i) ;
        output.println( block.getXpos() + "," + block.getYpos() + "," + block.getType() + "," + block.getPin() ) ;
    }

    output.println(links.size());           // the amount of links is saved
    for (int i = 0; i < links.size(); i++ )
    {
        Link link = links.get(i) ;
        println("N nodes = " + (link.getNlinks()-1) ) ;

        int Q       = link.getQ() ;
        int IN1     = link.getIn(0) ;
        int IN2     = link.getIn(1) ;
        int IN3     = link.getIn(2) ;
        int subrow  = link.getSubrow() ;

        println("  Q: " +   Q ) ;
        println("IN1: " + IN1 ) ;
        println("IN2: " + IN1 ) ;
        println("IN3: " + IN2 ) ;
        println("subrow: " + subrow ) ;

        output.print( Q + "," + IN1 + "," + IN2 + "," +IN3 + "," + subrow ) ;

        for (int j = 0 ; j < 50 ; j++ ) 
        {
            output.print( "," + link.getPosX(j) + "," + link.getPosY(j) + ","  // store all 50 coordinates
                              + link.getSubX(j) + "," + link.getSubY(j) ) ;
        }
        output.println() ;  // newline
    }  
    output.close();
}



void loadLayout()
{
    println("LAYOUT LOADED");
    String line = "" ;

   
    try {
        input = createReader("program.csv"); 
        line = input.readLine();
    } 
    catch (IOException e) { return ;}
    catch (NullPointerException e ) {return ;}
    
    int size = Integer.parseInt(line);
    
    for( int j = 0 ; j < size ; j++ )
    {
        try { line = input.readLine(); } 
        catch (IOException e) {return ;}
        
        String[] pieces = split(line, ',');
        int X    = Integer.parseInt( pieces[0] );
        int Y    = Integer.parseInt( pieces[1] );
        int type = Integer.parseInt( pieces[2] );
        int  pin = Integer.parseInt( pieces[3] );

        blocks.add( new FunctionBlock(X, Y, type, gridSize ) ) ;
        
        FunctionBlock block = blocks.get(j) ;
        block.setPin( pin ) ;
    } 

    try { line = input.readLine(); } 
    catch (IOException e) {}

    size = Integer.parseInt(line);

    for( int i = 0 ; i < size ; i++ ) 
    {
        try { line = input.readLine(); } 
        catch (IOException e) {}
         
        String[] pieces = split(line, ',');
        int Q       = Integer.parseInt( pieces[0] );
        int IN1     = Integer.parseInt( pieces[1] );
        int IN2     = Integer.parseInt( pieces[2] );
        int IN3     = Integer.parseInt( pieces[3] );
        int subrow  = Integer.parseInt( pieces[4] );
        int x1      = Integer.parseInt( pieces[5] );
        int y1      = Integer.parseInt( pieces[6] );
        //int s1    = Integer.parseInt( pieces[7] );
        //int s2    = Integer.parseInt( pieces[8] );

        links.add( new Link( x1, y1, gridSize, Q ) ) ;
        Link link = links.get(i) ;

        switch( subrow )
        {
            case 0 : link.setIn(subrow,IN1) ; break ;
            case 1 : link.setIn(subrow,IN2) ; break ;
            case 2 : link.setIn(subrow,IN3) ; break ;
        }

        println("\r\nTWO Q: " +  Q  ) ;
        println("IN1:    " +    IN1 ) ;
        println("IN2:    " +    IN2 ) ;
        println("IN3:    " +    IN3 ) ;
        println("subrow: " + subrow ) ;

        for( int j = 9 ; j < (50*4) + 1 ; j += 4 )      // 50 XY coordinates and 50 subX subY coordinates and we start at the 8th byte
        {      
            int colX = Integer.parseInt( pieces[  j  ] ) ;
            int colY = Integer.parseInt( pieces[ j+1 ] ) ;
            int subX = Integer.parseInt( pieces[ j+2 ] ) ;
            int subY = Integer.parseInt( pieces[ j+3 ] ) ;

            if( colX == 0 && colY == 0
            &&  subX == 0 && subY == 0 ) break ;

            link.updatePoint( colX, colY, subX, subY ) ;
            link.storePoint() ;
        } 

        link.removePoint() ;
        linkIndex ++ ;
    }
}

void assembleProgram() 
{
    file = createWriter("arduinoProgram/arduinoProgram.ino");
    file.println("#include \"functionBlocks.h\"") ;
    file.println("") ;
    for( int i = 0 ; i < blocks.size() ; i ++ )
    {
        FunctionBlock block = blocks.get( i ) ;
        int type  = block.getType() ;
        int time  = 1 ; //block.get
        int  pin  = block.getPin() ;
        switch( type )
        {
            case    AND: file.println("static    And b"+(i+1)+" =    And() ;") ;            break ;
            case     OR: file.println("static     Or b"+(i+1)+" =     Or() ;") ;            break ;
            case      M: file.println("static Memory b"+(i+1)+" = Memory() ;") ;            break ;
            case    DEL: file.println("static  Delay b"+(i+1)+" =  Delay("+ time +") ;") ;  break ;
            case    NOT: file.println("static    Not b"+(i+1)+" =    Not() ;") ;            break ;
            case  INPUT: file.println("static  Input b"+(i+1)+" =  Input("+ pin +") ;") ;   break ;
            case OUTPUT: file.println("static Output b"+(i+1)+" = Output("+ pin +") ;") ;   break ;
        }
    }
    file.println("") ;
    file.println("FunctionBlock *block[] = {") ;
    for( int i = 0 ; i < blocks.size() ; i ++ ) file.println("    &b"+ (i+1)+" ,") ;
    file.println("} ;") ;
    file.println("const int nBlocks = " + blocks.size() + " ;" ) ;
    file.println("") ;
    file.println("void setup()") ;
    file.println("{") ;
    file.println("}") ;
    file.println("") ;
    file.println("void loop()") ;
    file.println("{") ;
    file.println("/***************** UPDATE FUNCTION BLOCKS *****************/") ;
    file.println("    for( int i = 0 ; i < nBlocks ; i ++ ) block[i] -> run() ;") ;
    file.println("") ;
    file.println("/***************** UPDATE LINKS *****************/") ;
    for ( int i = 0 ; i < links.size() ; i ++ ) 
    {
        Link  link = links.get( i ) ;

        int      Q = link.getQ() ;
        int subrow = link.getSubrow() ;
        int     IN = link.getIn( subrow );

        println("Q: "   +  Q  ) ; // DELETE ME
        println("IN: " +    IN ) ;
        println("subrow: " + subrow ) ;

        file.println("    block["+IN+"] -> IN"+(subrow+1)+" = block["+Q+"] -> Q ;") ;
    }
    file.println("} ;") ;
    file.close() ;
}
