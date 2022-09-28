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
V make small nodes along link nodes, so you can see when lines just simply cross
// NOTE. Added different baseclass. This works well for the arduino, but I have the problem that the links and indices are screwed up.
// I think I also need to to add analog base class for
V may need to refactor to separate classes so it becomes easier to add the new analog items
V ID of Function blocks also need to be stored for the input and output blocks
- add method to update all links' Qs and INs for when a FB is removed or replaced. Currently links will point to the old index
  and this may or may not be correct...
V if mouse is clicked to alter pin/time number, the number should be initialized to 0. To work from the current value does not
  work as intuitive as I imagined.
V ditch the triangles for input/output and make them square like the others
V add serial input and serial output blocks, to send and receive messages over the serial port
V add D for all digital Pin numbers
V check if #error can be used to test the PWM pins for being an actual PWM pin note: it can be done
  but the syntax behind it is abysmal. I need like 3 helper function with vague c++ syntax to get it done
- add mouse images to git
V for the analog stuff, make a map block
- add code to insert constants for map block and constant block
- finalize the arduino code with the latest added components. (also replace constant class by an actual number in the generated links)
- Servo's still need a pin variable

EXTRA
- make comperator for usage with analog input
- make separate arrays for AND, NOR and MEMORIES. , unsure if actually needed, it may help with generating organized source code.
- also add NAND or NOR gates or implement inverted outputs !Q
- let textSize change appropiate with gridSize for all function blox
- add panning for larger layouts

BACKLOG
- move node of a line by dragging it with LMB

CURRENT WORK:
- The mouse functions have been refactored
- test the new link updates
- store the first and final coordinates directly
- fix the problem that links are out of synch with new digital and analog IO.
- adjusting gridSize, both FB and links work, but the subcoordinates of the mouse
  seems off, with different zoom levels it can be difficult to move an item or create a link..
  
possible solutions:
- store indices in the function blocks themselfes and keep track of separate indices
  for analog and digital IO.
- pass indices to the arduino, and figure that out.

notes:
- We do know when a link is digital or analog.

description of problem.

analog blocks need more bits for Q and IN. This needs special analog class for the arduino.
The arduino now has 2 types of blocks and 2 separated arrays for analog and digital. The links for analog is also
altered. The problem is that the indices of both analog as digital blocks can be in random order of processing.

This order cannot be maintained on the arduino because of the two separate arrays. 
The hard coded links still hace the random order in processing.

I really do not want to split the code for digital/analog in processing, despite that that will
fix the problem at hand.

One alternative I can think of, is to re-calculate the links' indices when the arduino
program is assembled. This can propably be done but I am not yet sure how yet.

during 'play' time I may be able to keep track of the amount of digital and analog 
components. Of I create a link on Q of block 13 and block 13 may be the 2nd analog one
I can set the link correctly to 1 instead of 12. 

I think this is the most viable fix with a relative least amount of work

I added counters for the amount of analog and digital blocks. These counters are used to store
the appriopiate index for every FB. The next step is use the new index variable to set the Q and IN
for links

Ok, storing the indices per block works but contains design flaws. If you remove blocks and add new ones
you may get screwed up numbers in the link arrays.

It is vital that links are continously updates at all times. Similarly, it is not needed to store the indices
per block. To update the links, one most cross reference XY coordinates of the first and last points to
the XY coordinates of the blocks. This will enforce correct values also when you replace function blocks

To to the above it is usefull to store X, Y subX, subY of the first and the last point. Currently the last point is the last 
in the point array.

The update link function should work. But it needs to be tested. Setting Q and IN happens at all times. For every
links, the begin and stop coordinates are fetched and than are crossreferenced with all present Function Blocks. 

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

final int   idle             = 0 ;
final int   movingItem       = 1 ;
final int   deletingItem     = 2 ;
final int   makingLinks      = 3 ;
final int   addingLinePoints = 4 ;
final int   settingNumber    = 5 ;
final int   settingDelayTime = 6 ;
final int   settingPulseTime = 7 ;

int         gridSize = 60 ;

final int DIGITAL_BLOCKS = 0 ;

final int        AND =  1 ;
final int         OR =  2 ;
final int          M =  3 ;
final int        NOT =  4 ;
final int      INPUT =  5 ;
final int     OUTPUT =  6 ;
final int         JK =  7 ;
final int      PULSE =  8 ;
final int     SER_IN =  9 ;
final int    SER_OUT = 10 ;

final int ANALOG_BLOCKS = 20 ;

final int     ANA_IN = 21 ;
final int    ANA_OUT = 22 ;
final int      SERVO = 23 ;
final int        MAP = 24 ;
final int       COMP = 25 ;
final int      DELAY = 26 ;
final int   CONSTANT = 27 ;


// digital input
// digital output
// potentiometer
// PWM
// SERVO
// occupanceDetector
// DCC accessory article,
// DCC loco function

/*
checklist adding new block
- Add one to the final ints
- declare the single demo object
- initialize the single demo object
- draw the demo object
- alter the draw method in the class
- add redundant items, like dedicated numbers, 
- add control texts
- add device to the arduino code

*/

int      col ;
int      row ;
int      subCol ;
int      subRow ;
int      nItems ;
boolean  locked ;
int      index ;
int      mode = idle ;
int      linkIndex = 0 ;
int      foundLinkIndex ;
int      currentType ;
int      pinNumber ;
int      delayTime ;

int      nAnalogBlocks ;
int      nDigitalBlocks ;

boolean  hoverOverFB ;
boolean  hoverOverPoint ;
boolean  blockMiddle ;

FunctionBlock or1 ;
FunctionBlock and1 ;
FunctionBlock sr1 ;
FunctionBlock delay1 ;
FunctionBlock not1 ;
FunctionBlock inp1 ;
FunctionBlock outp1 ;
FunctionBlock jk1 ;
FunctionBlock gen1 ;
FunctionBlock ana_in1 ;
FunctionBlock ana_out1 ;
FunctionBlock servo1 ;
FunctionBlock map1 ;
FunctionBlock comp1 ;
FunctionBlock ser_in1 ;
FunctionBlock ser_out1 ;
FunctionBlock const1 ;


void setup()
{
   
    //fullScreen() ;
    loadLayout() ;
    size(displayWidth, displayHeight) ;
    textSize( 20 );
    background(255) ;
    
    // LEFT COLUMN DIGITAL STUFFS
    and1      = new FunctionBlock((width-2*gridSize)/gridSize,  0,     AND, gridSize ) ;
    or1       = new FunctionBlock((width-2*gridSize)/gridSize,  1,      OR, gridSize ) ;
    sr1       = new FunctionBlock((width-2*gridSize)/gridSize,  2,       M, gridSize ) ;
    not1      = new FunctionBlock((width-2*gridSize)/gridSize,  3,     NOT, gridSize ) ;
    inp1      = new FunctionBlock((width-2*gridSize)/gridSize,  4,   INPUT, gridSize ) ;
    outp1     = new FunctionBlock((width-2*gridSize)/gridSize,  5,  OUTPUT, gridSize ) ;
    jk1       = new FunctionBlock((width-2*gridSize)/gridSize,  6,      JK, gridSize ) ;
    gen1      = new FunctionBlock((width-2*gridSize)/gridSize,  7,   PULSE, gridSize ) ;
    ser_in1   = new FunctionBlock((width-2*gridSize)/gridSize,  8,  SER_IN, gridSize ) ;
    ser_out1  = new FunctionBlock((width-2*gridSize)/gridSize,  9, SER_OUT, gridSize ) ;

    // RIGHT COLUMN ANALOG STUFFS
    ana_in1   = new FunctionBlock((width-1*gridSize)/gridSize,  0,   ANA_IN, gridSize ) ;
    ana_out1  = new FunctionBlock((width-1*gridSize)/gridSize,  1,  ANA_OUT, gridSize ) ;
    servo1    = new FunctionBlock((width-1*gridSize)/gridSize,  2,    SERVO, gridSize ) ;
    map1      = new FunctionBlock((width-1*gridSize)/gridSize,  3,      MAP, gridSize ) ;
    comp1     = new FunctionBlock((width-1*gridSize)/gridSize,  4,     COMP, gridSize ) ;
    delay1    = new FunctionBlock((width-1*gridSize)/gridSize,  5,    DELAY, gridSize ) ;
    const1    = new FunctionBlock((width-1*gridSize)/gridSize,  6, CONSTANT, gridSize ) ;
}

void draw()
{
    drawBackground() ;
    checkFunctionBlocks() ;
    checkLinePoints() ;
    printTexts() ;
    updateCursor() ;
    drawBlocks() ;
    updateLinks() ;
    drawLinks() ;
}


// MOUSE PRESSED FUNCTIONS
void addFunctionBlock()
{
    mode = movingItem ;

    if( mouseX > (width-gridSize)) currentType = row + 21 ; // hover over analog things
    else                           currentType = row +  1 ; // hover over digital things

    pinNumber = 0 ;

    blocks.add( new FunctionBlock(( width- 3*gridSize) / gridSize, row, currentType, gridSize )) ;    

    index = blocks.size() - 1 ;
    return ;
}

void moveItem()
{
    FunctionBlock block = blocks.get( index );

    if( col == block.getXpos() &&  row == block.getYpos() && blockMiddle == true )
    {
        mode = movingItem ;
        //index = i;
        return ;
    }
    //else index = 0 ;
}

void alterNumber()
{
    try
    {
        pinNumber = 0 ;
        delayTime = 0 ;

        FunctionBlock block = blocks.get( index ) ;
        int type = block.getType() ;
        if( type ==     DELAY ) mode = settingDelayTime ;
        if( type ==   PULSE ) mode = settingPulseTime ;
        if( type ==   INPUT
        ||  type ==  OUTPUT
        ||  type ==  ANA_IN
        ||  type == ANA_OUT ) mode = settingNumber ;
    } catch (IndexOutOfBoundsException e) {}
}

void createLink()
{
    mode = addingLinePoints ;

    int analogIO = 0 ;

    FunctionBlock block = blocks.get( index ) ;
    int type = block.getType() ;

    links.add( new Link( col, row, gridSize ) ) ;
    Link link = links.get( linkIndex ) ;
    link.updatePoint( col, row, subCol, subRow  ) ;
}

void finishLink()
{
    mode = idle ; 
    Link link = links.get( linkIndex ) ;
    linkIndex ++ ;
}

void addNodeToLink()
{
    Link link = links.get( linkIndex ) ;
    link.addPoint( ) ;
    link.updatePoint( col, row, subCol, subRow  ) ;
}

void deleteObject()
{
    FunctionBlock block = blocks.get( index ) ;
    int type = block.getType() ;

    if( type >= ANA_IN )  nAnalogBlocks -- ;
    else                 nDigitalBlocks -- ;

    blocks.remove(index);		                                            // DELETE THE OBJECT
    hoverOverFB = false ;
}

void removeNode()
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

void removeLink()
{
    println("foundLinkIndex: " + foundLinkIndex) ;
    links.remove( foundLinkIndex ) ;
    linkIndex -- ;
}

void dragItem() 
{
    FunctionBlock block = blocks.get(index);
    block.setPos(col,row);
}

void dragLine()
{
    Link link = links.get( linkIndex ) ;
    link.updatePoint( col, row, subCol, subRow  ) ;
}
// helper functions


void leftMousePress()
{
    if( mode == settingNumber || mode == settingDelayTime || mode == settingPulseTime ) return ;                               // as long as a number is set, LMB nor RMB must do anything

    if(      mode == idle && (mouseX > (width-2*gridSize)) )                     addFunctionBlock() ;
    else if( mode == idle ) for (int i = 0; i < blocks.size(); i++)              moveItem() ;
    if (     mode == idle && subCol == 1 && subRow == 2 && hoverOverFB == true ) alterNumber() ;
    else if( mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true ) createLink() ;
    else if( mode == addingLinePoints && subCol == 0    && hoverOverFB == true ) finishLink() ;
    else if( mode == addingLinePoints )                                          addNodeToLink() ; 
}

void rightMousePress()
{
    if( mode == settingNumber ) return ;                                        // as long as a number is set, LMB nor RMB must do anything

    if( mode == idle 
    && blocks.size() > 0 
    &&  index < blocks.size() 
    && hoverOverFB == true
    && blockMiddle == true )                deleteObject() ;  
    else if( mode == addingLinePoints )     removeNode() ;
    else if( hoverOverPoint )               removeLink() ;
}
void mousePressed()
{	
    if( mouseButton ==  LEFT )              leftMousePress() ;
    if( mouseButton == RIGHT )              rightMousePress() ;
}
void mouseDragged()
{
    if( mode == movingItem )                dragItem() ;
}
void mouseMoved()
{
    if( mode == addingLinePoints )          dragLine() ;
}
void mouseReleased()
{
    if( mode == movingItem )                mode = idle ;
}

void mouseWheel(MouseEvent event)
{
    float e = event.getCount();
    if( e > 0 && gridSize < 40 ) return ;
    gridSize -= 5* (int) e ;
    println( gridSize ) ;
}


void drawBackground()
{
    background(180) ;
    fill(255) ;
    rect(0,0,(width - 120) - 2 , (height - 120) - 2 ) ;

    textAlign(CENTER,CENTER);

    and1.draw() ;       // draw default items
    or1.draw() ;
    sr1.draw() ;
    delay1.draw() ;
    not1.draw() ;
    inp1.draw() ;
    outp1.draw() ;
    jk1.draw() ;
    gen1.draw() ;
    ana_in1.draw() ;
    ana_out1.draw() ;
    servo1.draw() ;
    map1.draw() ;
    comp1.draw() ; 
    ser_in1.draw() ;
    ser_out1.draw() ;
    const1.draw() ;
}

void updateLinks()
{
    for( int i = 0 ; i < links.size() ; i++ )  // get connected Q of the link
    {
        Link link = links.get(i) ;

        int start_x    = link.getStartPosX() ;
        int start_y    = link.getStartPosY() ;
        int start_subX = link.getStartSubX() ;
        int start_subY = link.getStartSubY() ;

        int stop_x     = link.getStopPosX() ;
        int stop_y     = link.getStopPosY() ;
        int stop_subX  = link.getStopSubX() ;
        int stop_subY  = link.getStopSubY() ;

        boolean Qfound  = false ;
        boolean INfound = false ;

        for( int j = 0 ; j < blocks.size() ; j++ )                              // this loops finds who's Q is attached to this link
        {
            FunctionBlock block = blocks.get(j);
            int block_x    = block.getXpos() ;
            int block_y    = block.getYpos() ;
            int isAnalog   = block.isAnalog() ;

            if( start_x == block_x && start_y == block_y
            &&  start_subX == 2    && start_subY == 1 
            && Qfound == false )
            {
                link.setQ( j ) ;
                link.setAnalogIn( isAnalog ) ;
                Qfound = true ;
            }

            if( stop_x == block_x && stop_y == block_y 
            &&  stop_subX == 0 
            &&  INfound   == false ) 
            {
                link.setIn( stop_subY, j ) ;
                INfound = true ;
            }
            
            if( INfound && Qfound ) break ;                                     // if both connections are found, break out of this for loop and go to the next link/
        }
    }
}

void drawLinks()
{
    for (int i = 0; i < links.size(); i++) 
    {
        Link link = links.get(i) ;
        link.setGridSize( gridSize ) ;
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
    if(hoverOverPoint == true ) text("line detected ",10,170);
    text("N analog  " + nAnalogBlocks, 10, 190);
    text("N digital " + nDigitalBlocks, 10, 210);
}

void printTexts()
{
    try
    { 
        FunctionBlock block = blocks.get(index);

        int type = block.getType() ;

        if(mouseX > (width-gridSize)  && mode == idle ) // seems to work very well
        {
            text1 = "New function block" ;
            text2 = "" ;
            // mouse = loadImage("images/mouse2.png") ;
        }
        else if(  mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true )
        {
            text1 = "create link" ;
            text2 = "delete link" ;
            // mouse = loadImage("images/mouse3.png") ;
        }
        else if( mode == idle && hoverOverFB  && blockMiddle == true )
        {
            text1 = "move item" ;
            text2 = "delete item" ;
            // mouse = loadImage("images/mouse3.png") ;
        }
        else if( mode == idle && hoverOverPoint )
        {
            text1 = "move node" ;
            text2 = "delete link" ;
            // mouse = loadImage("images/mouse3.png") ;
        }
        else if( mode == addingLinePoints && subCol == 0 && hoverOverFB == true )
        {
            text1 = "finish point" ;
            text2 = "" ;
            // mouse = loadImage("images/mouse2.png") ;
        }
        else if( mode == addingLinePoints )
        {
            text1 = "add point" ;
            text2 = "remove last point" ;
            // mouse = loadImage("images/mouse3.png") ;
        }
        else if( mode == movingItem)
        {
            text1 = "Moving function block" ;
            text2 = "" ;
            // mouse = loadImage("images/mouse2.png") ;
        }
        else if( mode == settingNumber )
        {
            text1 = "SET PIN NUMBER" ;
            text2 = "PRESS <ENTER> WHEN READY" ;
            // mouse = loadImage("images/mouse1.png") ;
        }
        else if((   type == INPUT  ||    type == OUTPUT 
        ||          type == ANA_IN ||    type == ANA_OUT ) 
        &&        subCol ==     1  &&  subRow ==      2  
        &&   hoverOverFB == true )
        {
            text1 = "SET PIN NUMBER" ;
            text2 = "" ;
            // mouse = loadImage("images/mouse2.png") ;
        }
        else if( mode == settingDelayTime )
        {
            text1 = "ENTER DELAY TIME" ;
            text2 = "PRESS <ENTER> WHEN READY" ;
            // mouse = loadImage("images/mouse1.png") ;
        }
        else if( type == DELAY && subCol == 1 && subRow == 2 && hoverOverFB == true )
        {
            text1 = "SET DELAY TIME" ;
            text2 = "" ;
            // mouse = loadImage("images/mouse2.png") ;
        }
        else if( mode == settingPulseTime )
        {
            text1 = "ENTER PULSE SWITCH TIME" ;
            text2 = "PRESS <ENTER> WHEN READY" ;
            // mouse = loadImage("images/mouse1.png") ;
        }
        else if( type == PULSE && subCol == 1 && subRow == 2 && hoverOverFB == true )
        {
            text1 = "SET PULSE TIME" ;
            text2 = "" ;
            // mouse = loadImage("images/mouse2.png") ;
        }
        else
        {
            text1 = "" ;
            text2 = "" ;
            // mouse = loadImage("images/mouse1.png") ;
        }
        //image(mouse, width/2-gridSize, gridSize/5,gridSize,gridSize);
        textSize(gridSize/2);  
        textAlign(RIGHT,TOP);
        text( text1,  width/2 - gridSize, 0 ) ;
        textAlign(LEFT,TOP);
        text( text2, width/2, 0 ) ;
        textAlign(CENTER,CENTER);
    }
    catch (IndexOutOfBoundsException e) {}
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
    
    if( mode == settingNumber || mode == settingDelayTime || mode == settingPulseTime )
    {
        if( keyCode == ENTER )
        {
            mode = idle ;
            return ;
        }
        else
        {
            FunctionBlock block = blocks.get( index ) ;
            if( mode == settingNumber )
            {
                pinNumber = makeNumber( pinNumber, 0, 31) ;
                block.setPin( pinNumber ) ;
            }
            else
            {
                delayTime = makeNumber( delayTime, 0, 60000 ) ;
                block.setDelay( delayTime ) ; // used for delay and pulse generator
            }
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
        output.println( block.getXpos() + "," + block.getYpos() + "," + block.getType() + "," + block.getPin() + "," + block.getDelay() ) ;
    }

    output.println(links.size());           // the amount of links is saved
    for (int i = 0; i < links.size(); i++ )
    {
        Link link = links.get(i) ;
        println("N nodes = " + (link.getNlinks()-1) ) ;

        int Q        = link.getQ() ;
        int IN1      = link.getIn(0) ;
        int IN2      = link.getIn(1) ;
        int IN3      = link.getIn(2) ;
        int subrow   = link.getSubrow() ;
        int isAnalog =1;//= link.isAnalogIO() ;

        output.print( Q + "," + IN1 + "," + IN2 + "," +IN3 + "," + subrow ) ;

        for (int j = 0 ; j < 50 ; j++ ) 
        {
            output.print( "," + link.getPosX(j) + "," + link.getPosY(j) + ","  // store all 50 coordinates
                              + link.getSubX(j) + "," + link.getSubY(j) ) ;
        }
        output.println( "," + isAnalog ) ;
        if( isAnalog > 0 ) { println("ANALOG LINK stored BRUH!!") ; }
        
        //output.println() ;  // newline
    }  
    output.close();
}



void loadLayout()
{
    println("LAYOUT LOADED");
    String line = "" ;

    try
    {
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
        int X     = Integer.parseInt( pieces[0] );
        int Y     = Integer.parseInt( pieces[1] );
        int type  = Integer.parseInt( pieces[2] );
        int  pin  = Integer.parseInt( pieces[3] );
        int time  = Integer.parseInt( pieces[4] );

        blocks.add( new FunctionBlock(X, Y, type, gridSize ) ) ;
        if( type >= ANA_IN )  nAnalogBlocks ++ ;
        else                 nDigitalBlocks ++ ;
        
        FunctionBlock block = blocks.get(j) ;
        block.setPin( pin ) ;
        block.setDelay( time ) ;
    } 

    try { line = input.readLine(); } 
    catch (IOException e) {}
    println(line)  ;

    size = Integer.parseInt(line);

    for( int i = 0 ; i < size ; i++ ) 
    {
        try { line = input.readLine(); } 
        catch (IOException e) {}
         
        String[] pieces = split(line, ',');
        int Q        = Integer.parseInt( pieces[0] );
        int IN1      = Integer.parseInt( pieces[1] );
        int IN2      = Integer.parseInt( pieces[2] );
        int IN3      = Integer.parseInt( pieces[3] );
        int subrow   = Integer.parseInt( pieces[4] );
        int x1       = Integer.parseInt( pieces[5] );
        int y1       = Integer.parseInt( pieces[6] );
        //int s1     = Integer.parseInt( pieces[7] );
        //int s2     = Integer.parseInt( pieces[8] );
        int isAnalog = Integer.parseInt( pieces[205] ) ;

        if( isAnalog > 0 ) { println("ANALOG LINK loaded BRUH!!") ; }

        links.add( new Link( x1, y1, gridSize ) ) ;
        Link link = links.get(i) ;

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
    int index = 0 ;

    int nDigitalBlocks ;
    int nAnalogBlocks ;

    for( int i = 0 ; i < blocks.size() ; i ++ )     // store digital components
    {
        FunctionBlock block = blocks.get( i ) ;
        int  type = block.getType() ;
        int  time = block.getDelay() ;
        int   pin = block.getPin() ;

        // Add code to keep track of servo objects, their indices need to be stored
        
        switch( type )
        {   // digital types
            case     AND: file.println("static       And D"+(index+1)+" =        And() ;") ;           index++ ; break ;
            case      OR: file.println("static        Or D"+(index+1)+" =         Or() ;") ;           index++ ; break ;
            case       M: file.println("static    Memory D"+(index+1)+" =     Memory() ;") ;           index++ ; break ;
            case     NOT: file.println("static       Not D"+(index+1)+" =        Not() ;") ;           index++ ; break ;
            case      JK: file.println("static        Jk D"+(index+1)+" =         Jk() ;") ;           index++ ; break ;
            
            case   INPUT: file.println("static     Input D"+(index+1)+" =      Input("+  pin +") ;") ; index++ ; break ;
            case  OUTPUT: file.println("static    Output D"+(index+1)+" =     Output("+  pin +") ;") ; index++ ; break ;
            case   PULSE: file.println("static     Pulse D"+(index+1)+" =      Pulse("+ time +") ;") ; index++ ; break ;  
            case  SER_IN: file.println("static  SerialIn D"+(index+1)+" =   SerialIn("+ time +") ;") ; index++ ; break ;  
            case SER_OUT: file.println("static SerialOut D"+(index+1)+" =  SerialOut("+ time +") ;") ; index++ ; break ;  
        }
    }
    nDigitalBlocks = index ; 

    index = 0 ;
    for( int i = 0 ; i < blocks.size() ; i ++ )  // store analog components
    {
        FunctionBlock block = blocks.get( i ) ;
        int type  = block.getType() ;
        int time  = block.getDelay() ;
        int  pin  = block.getPin() ;
        
        switch( type )
        {   // analog types
            case      ANA_IN:  file.println( "static  AnalogInput A"+(index+1)+" =  AnalogInput("+  pin +") ;") ; index++ ; break ;
            case     ANA_OUT:  file.println( "static AnalogOutput A"+(index+1)+" = AnalogOutput("+  pin +") ;") ; index++ ; break ;
            case        COMP:  file.println( "static   Comperator A"+(index+1)+" =   Comperator() ;") ;           index++ ; break ;
            case       SERVO:  file.println( "static   ServoMotor A"+(index+1)+" =   ServoMotor("+  pin +") ;") ; index++ ; break ;
            case       DELAY:  file.println( "static        Delay A"+(index+1)+" =        Delay("+ time +") ;") ; index++ ; break ;
            //case         MAP:  file.println( "static          Map A"+(index+1)+" =          Map("+in1+","+in2+","+out1+","+out2+") ;") ;   index++ ; break ;
        }
    }
    nAnalogBlocks = index ;

    file.println("") ;
    file.println("DigitalBlock *digitalBlock[] = {") ;
    for( int i = 0 ; i < nDigitalBlocks ; i ++ ) file.println("    &D"+ (i+1)+" ,") ;
    file.println("} ;") ;
    file.println("const int nDigitalBlocks = " + nDigitalBlocks + " ;" ) ;
    file.println("") ;
    file.println("AnalogBlock *analogBlock[] = {") ;
    for( int i = 0 ; i < nAnalogBlocks ; i ++ ) file.println("    &A"+ (i+1)+" ,") ;
    file.println("} ;") ;
    file.println("const int nAnalogBlocks = " + nAnalogBlocks + " ;" ) ;
    file.println("") ;
    file.println("void updateLinks()") ;
    file.println("{") ;
    
    for ( int i = 0 ; i < links.size() ; i ++ ) 
    {
        Link  link = links.get( i ) ;

        int         Q = link.getQ() ;
        int    subrow = link.getSubrow() ;
        int        IN = link.getIn( subrow ) ;
        int  analogIn = link.isAnalogIn() ;
        int analogOut = link.isAnalogOut() ;


    // example: analogBlock[0] -> IN2 = digitalBlock[1] -> Q ;
        file.print("    ") ;
        if( analogIn > 0 )  file.print(" analogBlock" ) ;
        else                file.print("digitalBlock" ) ;
        file.print("["+IN+"] -> IN" +(subrow+1)+" = " ) ;

        if( analogOut > 0 )  file.print(" analogBlock" ) ;
        else                 file.print("digitalBlock" ) ;
        file.println( "["+Q+"] -> Q ;") ;
    }
    file.println("}") ;
    file.println("") ;
    file.println("void sendMessage( String S )") ;
    file.println("{") ;
    file.println("    Serial.println( S ) ;") ;
    file.println("}") ;
    file.println("String getMessage()") ;
    file.println("{") ;
    file.println("    static String lastMessage ;") ;
    file.println("") ;
    file.println("    if( Serial.available() ) // <== incomming message ;") ;
    file.println("    {") ;
    file.println("        lastMessage = \"\" ;          ") ;
    file.println("        delay(3) ;          // use dirty delay to receive entire message") ;
    file.println("") ;
    file.println("        while( Serial.available() )") ;
    file.println("        {") ;
    file.println("            char c = Serial.read() ;") ;
    file.println("            lastMessage += c ;") ;
    file.println("        }") ;
    file.println("    }") ;
    file.println("") ;
    file.println("    return lastMessage ;") ;
    file.println("}   ") ;
    file.println("") ;
    file.println("void setup()") ;
    file.println("{") ;
    file.println("    // NOTE init servo motors") ;
    file.println("    Serial.begin( 115200 ) ;") ;
    file.println("}") ;
    file.println("") ;
    file.println("void loop()") ;
    file.println("{") ;
    file.println("/***************** UPDATE FUNCTION BLOCKS *****************/") ;
    file.println("    for( int i = 0 ; i < nDigitalBlocks ; i ++ ) { digitalBlock[i] -> run() ; updateLinks() ; }") ;
    file.println("    for( int i = 0 ; i <  nAnalogBlocks ; i ++ ) {  analogBlock[i] -> run() ; updateLinks() ; }") ;
    file.println("}") ;
    file.close() ;
}