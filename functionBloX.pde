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
V create special items like servo motors, blinking lights (auto toggling IO): servo exists but only in arduino. Blinking lights can be done via pulse generator
V make variable gridsize workable
V store and load layout, add buttons.
V add small sphere to mouse if there is anything to click. perhaps half green and half red to indicate which buttons can be pressed
V make small nodes along link nodes, so you can see when lines just simply cross
V may need to refactor to separate classes so it becomes easier to add the new analog items
V ID of Function blocks also need to be stored for the input and output blocks
V add method to update all links' Qs and INs for when a FB is removed or replaced. Currently links will point to the old index
  and this may or may not be correct...
V if mouse is clicked to alter pin/time number, the number should be initialized to 0. To work from the current value does not
  work as intuitive as I imagined.
V ditch the triangles for input/output and make them square like the others
V add serial input and serial output blocks, to send and receive messages over the serial port
V add D for all digital Pin numbers
V check if #error can be used to test the PWM pins for being an actual PWM pin note: it can be done
  but the syntax behind it is abysmal. I need like 3 helper function with vague c++ syntax to get it done
V add mouse images to git
V for the analog stuff, make a map block
V add code to insert constants for map block and constant block
V finalize the arduino code with the latest added components. (also replace constant class by an actual number in the generated links)
V Servo's still need a pin variable
V fix that new function blocks are created more to the left, and limit the cursor not to include the left colomn of default blocks
V store the new values of a map block.
- refactor the code and add comments somewhere to show how it is organized. The comments must be able to be used to find the code easily.
    perhaps also a list with commented function prototypes of all functions?
V Texts on main screen are related to gridSize... kill that!
V if not yet done, Links cannot be removed by right mousing buttoning on the last node
V map values need to be rearanged, so like 
  in1   in2
      in
      MAP
      out
 out1   out2
 V map values are not set int he arduino program
V insert messages for serial input and output
- if gridSize is not 60, placing compenents suck balls
- initialize servo objects
- enter the texts for serial blocks
  setup
  loop
  mouse functions
  keyboard functions
  round robin tasks
  saving and storeing

LIST OF BLOCKS TO ADD
- loconet -> loco drive
- loconet -> loco function
- loconet -> point (send)
- loconet -> point (received)
- loconet -> feedback
- loconet -> railcom (must be simultaneous with the feedback)

- arithmatic blocks? +, -, /, *


BACKLOG
V make comperator for usage with analog input
X make separate arrays for AND, NOR and MEMORIES. , unsure if actually needed, it may help with generating organized source code.
V let textSize change appropiate with gridSize for all function blox
V split the 2 columns on the right, 1 for analog, 1 for digital.
- make a list for the things to add
V find a way to let a digital Q set an IN of an analog block. 0-1 can be remapped to lets say 0-180..
V similarly a comperator must be able to set a digital IN
- remove obsolete debug texts

EXTRA
X make separate arrays for AND, NOR and MEMORIES. , unsure if actually needed, it may help with generating organized source code.
- also add NAND or NOR gates or implement inverted outputs !Q
V let textSize change appropiate with gridSize for all function blox
- add panning for larger layouts
- exclude top row and first column for cosmetic purposes. It would be neat if we can stuff control buttons there.
- move node of a line by dragging it with LMB
- implement inverted outputs !Q
- if zoomed in, the components can be drawn in the yellow zone.. and
  if zoomed out we cannot reach the bottom right zone of the blue zone...


CURRENT WORK:
- add the texts for serial blocks, use the upper texts..


STUFF TO ADD

ANALOG:
    SERVO 
    MAP
    SERIAL PRINT A NUMBER
    CONSTANTS (as input)
    COMPARATOR
    ANALOG DELAY (increments or decrements an IN with 1 at the time)

DIGITAL
    Serial read and print messages
    check if a D latch or D flip flop is at all usefull considering that we already have a JK FF

3 events:
mouse pressed ==> create line object and store initial X/Y coordinates. Inc point index
mouse drag    ==> update the current element with new X/Y coordinates
mouse release ==> increment the index counter
mousewheel    ==> alter grid size

*/

color backGroundColor = 100 ; 
color mainPanel  = 200 ;
// color mainPanel  = #5C4033 ; dark brown 
color fbColor    = #97db61  ;
color textColor  = 0 ;

PrintWriter     file ;
PrintWriter     output;
BufferedReader  input;
PImage          mouse;

ControlButton saveButton    ;
ControlButton programButton ;
ControlButton quitButton ;

String text1 = "" ;
String text2 = "" ;

ArrayList <FunctionBlock> demoBlocks = new ArrayList() ;
ArrayList <FunctionBlock>     blocks = new ArrayList() ;
ArrayList <Link>              links  = new ArrayList() ;

final int   idle             = 0 ;
final int   movingItem       = 1 ;
final int   deletingItem     = 2 ;
final int   makingLinks      = 3 ;
final int   addingLinePoints = 4 ;
final int   settingPin       = 5 ;
final int   settingDelayTime = 6 ;
final int   settingPulseTime = 7 ;
final int   settingMapValues = 8 ;
final int   settingMessage   = 9 ;

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


/*
checklist adding new block
- Add one to the final ints
- add demo object to the array
- alter the draw method in the class (text and connection lines)
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
int      mapState ;
int      in1, in2, out1, out2 ;

int     linkQ ;
int     linkIn ;
int     linkRow ;
int     analogQ ;
int     analogIn ;
int     indexOfBlock ;

int      nAnalogBlocks ;
int      nDigitalBlocks ;

boolean  hoverOverFB ;
boolean  hoverOverPoint ;
boolean  blockMiddle ;

void setup()
{ 
    //fullScreen() ;
    loadLayout() ;
    size(displayWidth, displayHeight) ;
    textSize( 20 );
    background(255) ;
    
    // LEFT COLUMN DIGITAL STUFFS
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  0,     AND, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  1,      OR, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  2,       M, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  3,     NOT, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  4,   INPUT, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  5,  OUTPUT, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  6,      JK, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  7,   PULSE, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  8,  SER_IN, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize,  9, SER_OUT, gridSize ) ) ;

    // RIGHT COLUMN ANALOG STUFFS
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  0,   ANA_IN, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  1,  ANA_OUT, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  2,    SERVO, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  3,      MAP, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  4,     COMP, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  5,    DELAY, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  6, CONSTANT, gridSize ) ) ;

    saveButton    = new ControlButton(  10, height - 100, "SAVE" ) ;
    programButton = new ControlButton( 120, height - 100, "PROGRAM") ;
    quitButton    = new ControlButton( width-110, height - 100, "QUIT") ;
}

void draw()
{
    drawBackground() ;
    checkFunctionBlocks() ;
    checkLinePoints() ;
    printTexts() ;
    updateBlocks() ;
    drawBlocks() ;
    updateLinks() ;
    drawLinks() ;
    controlButtons() ;
    updateCursor() ;
}


// mouse PRESSED FUNCTIONS
void addFunctionBlock()
{
    int row =    mouseY / 60 ;
    mode = movingItem ;

    if( mouseX > (width-60)) currentType = row + 21 ; // hover over analog things
    else                     currentType = row +  1 ; // hover over digital things

    pinNumber = 0 ;

    blocks.add( new FunctionBlock(( width- 3*60) / 60, row, currentType, 60 )) ;    

    index = blocks.size() - 1 ;
}

void moveItem()
{
    try
    {
        FunctionBlock block = blocks.get( index ); // DEBUG NEED A TRY N CATCH.. 3x happened

        if( col == block.getXpos() &&  row == block.getYpos() && blockMiddle == true )
        {
            mode = movingItem ;
        }
    }
    catch( IndexOutOfBoundsException e ) {}
}

void alterNumber()
{
    try
    {
        pinNumber = 0 ;
        delayTime = 0 ;

        FunctionBlock block = blocks.get( index ) ;
        int type = block.getType() ;
        if( type ==   DELAY 
        ||  type == CONSTANT) mode = settingDelayTime ;
        if( type ==   PULSE ) mode = settingPulseTime ;
        if( type ==     MAP ) mode = settingMapValues ;
        if( type ==  SER_IN
        ||  type == SER_OUT ) mode = settingMessage ;
        if( type ==   INPUT
        ||  type ==  OUTPUT
        ||  type ==  ANA_IN
        ||  type ==   SERVO
        ||  type == ANA_OUT ) mode = settingPin ;
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
    if( mode == settingPin || mode == settingDelayTime || mode == settingPulseTime 
    ||  mode == settingMapValues || mode == settingMessage ) return ;                               // as long as a number is set, LMB nor RMB must do anything

    if(      mode == idle && (mouseX > (width-2*60)) )                           addFunctionBlock() ;
    else if( mode == idle )                                                      moveItem() ;
    if (     mode == idle && subCol == 1 && subRow == 2 && hoverOverFB == true ) alterNumber() ;
    else if( mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true ) createLink() ;
    else if( mode == addingLinePoints && subCol == 0    && hoverOverFB == true ) finishLink() ;
    else if( mode == addingLinePoints )                                          addNodeToLink() ; 
}

void rightMousePress()
{
    if( mode == settingPin ) return ;                                        // as long as a number is set, LMB nor RMB must do anything

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
    if(( e > 0 && gridSize <  35 )
    || ( e < 0 && gridSize > 135 )) return ;
    gridSize -= 15* (int) e ;
    println( gridSize ) ;
}


void drawBackground()
{
    // background(0x9b,0x87,0x0c) ; backGroundColor = 0xAb970c ;
    background( backGroundColor  ) ;
    fill( mainPanel) ;
    rect(5,5,(width - 120) - 2 , (height - 120) - 2 ) ;

    textAlign(CENTER,CENTER);
    for( int i = 0 ; i < demoBlocks.size() ; i ++ )
    {
        FunctionBlock block = demoBlocks.get(i) ;
        block.draw() ;
    }
}

void controlButtons()
{
    text1 = "" ;
    textSize(30);  
    
    if( saveButton.draw() ) 
    {
        text1 = "SAVE LAYOUT" ;
        if( mousePressed )
        {
            saveLayout() ;
            delay( 1000 ) ;
        }
    }
    if( programButton.draw() ) 
    {
        text1 = "ASSEMBLE\r\nPROGRAM" ;
        if( mousePressed )
        {
            assembleProgram() ;
            delay( 1000 ) ;
        }
    }
    if( quitButton.draw() )
    {
        text1 = "QUIT PROGRAM" ;
        if( mousePressed )
        {
            exit() ;
        }
    }
    textSize(30);  
    textAlign(RIGHT,TOP);
    text( text1,  width/2 - 60, 10 ) ;
}

void updateBlocks()
{
    int analogIndex  = 0 ;
    int digitalIndex = 0 ;
    for( int i = 0 ; i < blocks.size() ; i++ ) 
    {
        FunctionBlock block = blocks.get(i) ;
        int type = block.getType() ;
        //if( type == CONSTANT ) continue ;
        if( type >= ANA_IN ) { block.setIndex(  analogIndex ++ ) ; }
        else                 { block.setIndex( digitalIndex ++ ) ; }
    }
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
            int index      = block.getIndex() ;

            if( start_x == block_x && start_y == block_y
            &&  start_subX == 2    && start_subY == 1 
            && Qfound == false )
            {
                analogQ = isAnalog ;    // debug
                linkQ = index ;         // debug
                link.setAnalogOut(isAnalog) ;
                link.setQ( index ) ;
                Qfound = true ;
            }
            else if( Qfound == false ) link.setQ( 255 ) ;

            if( stop_x == block_x && stop_y == block_y 
            &&  stop_subX == 0 
            &&  INfound   == false ) 
            {
                analogIn = isAnalog ;
                linkIn = index ;        // debug
                linkRow = stop_subY ;   // debug
                link.setAnalogIn(isAnalog) ;
                link.setIn( stop_subY, index ) ;
                INfound = true ;
            }
            else if( INfound == false ) link.setIn( stop_subY, 255 ) ;
            
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
            indexOfBlock = block.getIndex() ;
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
        
        for( int j = 0 ; j < link.getNlinks()+1 ; j++ )
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
    int max_col = (width - 3*gridSize) / gridSize ;
    col = constrain( col, 0, max_col ) ;

    row =    mouseY / gridSize ;
    int max_row = (height - 3*gridSize ) / gridSize ;
    row = constrain( row, 0, max_row ) ;

    if( mode != movingItem )
    {
        subCol = mouseX / (gridSize/3) % 3 ; // NOTE this suck balls when the gridSize is not divisable by 3
        subRow = mouseY / (gridSize/3) % 3 ;
    }  
   

    textAlign(LEFT,TOP);
    textSize(20);    
    text("X: " + col,10,50);                                                         // row and col on screen.
    text("Y: " + row,10,70);
    text("index: "+ index,10,90);  text("index2: "+ indexOfBlock,200,90);
    text("mode " + mode,10,110);
    text("subCol " + subCol,10,130);
    text("subRow " + subRow,10,150);
    if(hoverOverPoint == true ) text("line detected ",10,170);
    text("linkQ   " + linkQ, 10, 190);
    text("linkIn  " + linkIn, 10, 210);
    text("linkRow " + linkRow, 10, 230);
    text("analogQ " + analogQ, 10, 250);
    text("analogIn " + analogIn, 10, 270);

    if( text1 != "" || text2 != "" )
    {
        fill(255) ;
        arc(mouseX, mouseY, 10, 10, 0, 2*PI );
    }
    fill(0);
}

void printTexts()
{
    try
    { 
        FunctionBlock block = blocks.get(index);

        int type = block.getType() ;

        text1 = "";
        text2 = "";

        if(mouseX > (width-2*gridSize) 
        && mouseY < (height - 150) 
        && mode == idle ) // seems to work very well
        {
            text1 = "NEW FUNCTION BLOCK" ;
            text2 = "" ;
        }
        else if(  mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true )
        {
            text1 = "CREATE LINK" ;
            if(hoverOverPoint == true )
            {
                text2 = "DELETE LINK" ;
            }
        }
        else if( mode == idle && hoverOverFB  && blockMiddle == true )
        {
            text1 = "MOVE ITEM" ;
            text2 = "DELETE ITEM" ;
        }
        else if( mode == idle && hoverOverPoint )
        {
            text1 = "MOVE NODE" ;
            text2 = "DELETE LINK" ;
        }
        else if( mode == addingLinePoints && subCol == 0 && hoverOverFB == true )
        {
            text1 = "FINISH POINT" ;
            text2 = "" ;
        }
        else if( mode == addingLinePoints )
        {
            text1 = "ADD POINT" ;
            text2 = "REMOVE LAST POINT" ;
        }
        else if( mode == movingItem)
        {
            text1 = "MOVING FUNCTION BLOCK" ;
            text2 = "" ;
        }
        else if( mode == settingPin )
        {
            text1 = "SET PIN NUMBER" ;
            text2 = "PRESS <ENTER> WHEN READY" ;
        }
        else if( mode == settingDelayTime )
        {
            text1 = "ENTER DELAY TIME" ;
            text2 = "PRESS <ENTER> WHEN READY" ;
        }
        else if( subCol == 1 && subRow == 2 && hoverOverFB == true && mode == idle )
        {
            if( type == INPUT  || type == OUTPUT 
            ||  type == ANA_IN || type == ANA_OUT 
            ||  type == SERVO )
            {
                text1 = "SET PIN NUMBER" ;
                text2 = "" ;
            }
            else if( type == DELAY || type == CONSTANT )
            {
                if( type == DELAY ) text1 = "SET DELAY TIME" ;
                else                text1 = "SET VALUE" ;
                text2 = "" ;
            }
            else if( type == MAP )
            {
                text1 = "SET MAP VALUES" ;
                text2 = "" ;
            }
            else if( type == PULSE )
            {
                text1 = "SET PULSE TIME" ;
                text2 = "" ;
            }
        }
        else if( mode == settingPulseTime )
        {
            text1 = "ENTER PULSE SWITCH TIME" ;
            text2 = "PRESS <ENTER> WHEN READY" ;
        }
        else if( mode == settingMapValues )
        {
            switch( mapState )
            {
                case 0: text1 = "SET IN 1"  ; break ;
                case 1: text1 = "SET IN 2"  ; break ;
                case 2: text1 = "SET OUT 1" ; break ;
                case 3: text1 = "SET OUT 2" ; break ;
            }
            text2 = "PRESS <ENTER> WHEN READY" ;
        }
        else
        {
            text1 = "" ;
            text2 = "" ;
            mouse = loadImage("images/mouse1.png") ;
        }
        if(      text1 == "" && text2 != "" ) mouse = loadImage("images/mouse4.png") ;
        else if( text1 != "" && text2 == "" ) mouse = loadImage("images/mouse2.png") ;
        else if( text1 != "" && text2 != "" ) mouse = loadImage("images/mouse3.png") ;
        else                                  mouse = loadImage("images/mouse1.png") ;

        image(mouse, width/2-gridSize, gridSize/5,gridSize,gridSize);
        textSize(30);  
        textAlign(RIGHT,TOP);
        text( text1,  width/2 - 60, 10 ) ;
        textAlign(LEFT,TOP);
        text( text2, width/2, 10 ) ;
        textAlign(CENTER,CENTER);
    }
    catch (IndexOutOfBoundsException e) {}
}



int makeNumber(int _number, int lowerLimit, int upperLimit )
{
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
    
    if( mode == settingPin       || mode == settingDelayTime 
    ||  mode == settingPulseTime || mode == settingMapValues 
    ||  mode == settingMessage   )
    {
        if( keyCode == ENTER )
        {
            if( mode == settingMapValues )
            {
                if( ++ mapState == 4 ) mapState = 0 ;
                else return ;
            }
            mode = idle ;
            return ;
        }
        else
        {
            FunctionBlock block = blocks.get( index ) ;
            if( mode == settingPin )
            {
                pinNumber = makeNumber( pinNumber, 0, 31) ;
                block.setPin( pinNumber ) ;
            }
            else if( mode == settingMapValues )
            {
                switch( mapState )
                {
                    case 0: in1  = makeNumber(  in1, 0, 60000 ) ;block.setIn1( in1) ; break ;
                    case 1: in2  = makeNumber(  in2, 0, 60000 ) ;block.setIn2( in2) ; break ;
                    case 2: out1 = makeNumber( out1, 0, 60000 ) ;block.setOut1(out1) ; break ;
                    case 3: out2 = makeNumber( out2, 0, 60000 ) ;block.setOut2(out2) ; break ;
                }
            }
            else
            {
                delayTime = makeNumber( delayTime, 0, 60000 ) ;
                block.setDelay( delayTime ) ; // used for delay and pulse generator
            }
        }
    }
    if( key == 's' ) saveLayout() ;

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





/***************** SAVING, LOADING AND GENERATING SOURCE ***********/
void saveLayout()
{
    println("LAYOUT SAVED");

    output = createWriter("program.csv");

    output.println(blocks.size());          // the amount of elements is saved first, this is used for the loading
    for (int i = 0; i < blocks.size(); i++ )
    {
        FunctionBlock block = blocks.get(i) ;
        output.println( block.getXpos() + "," + block.getYpos() + "," 
                      + block.getType() + "," + block.getPin()  + "," 
                      + block.getDelay()+ "," 
                      + block.getIn1()  + "," + block.getIn2()  + "," 
                      + block.getOut1() + "," + block.getOut2() + "," ) ;
    }

    output.println(links.size());           // the amount of links is saved
    for (int i = 0; i < links.size(); i++ )
    {
        Link link = links.get(i) ;
        println("N nodes = " + (link.getNlinks()-1) ) ;

        int   Q      = link.getQ() ;
        int IN1      = link.getIn(0) ;
        int IN2      = link.getIn(1) ;
        int IN3      = link.getIn(2) ;
        int subrow   = link.getSubrow() ;
        int isAnalog = 1 ;//= link.isAnalogIO() ;

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
        int  in1  = Integer.parseInt( pieces[5] );
        int  in2  = Integer.parseInt( pieces[6] );
        int out1  = Integer.parseInt( pieces[7] );
        int out2  = Integer.parseInt( pieces[8] );

        blocks.add( new FunctionBlock(X, Y, type, gridSize ) ) ;

        if( type >= ANA_IN )  nAnalogBlocks ++ ;
        else                 nDigitalBlocks ++ ;
        
        FunctionBlock block = blocks.get(j) ;
        block.setPin( pin ) ;
        block.setDelay( time ) ;
        block.setIn1( in1 ) ;
        block.setIn2( in2 ) ;
        block.setOut1( out1 ) ;
        block.setOut2( out2 ) ;
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
        //int isAnalog = Integer.parseInt( pieces[205] ) ;

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
            case     AND: file.println("static          And d"+(index+1)+" = And() ;") ;                    index++ ; break ;
            case      OR: file.println("static           Or d"+(index+1)+" = Or() ;") ;                     index++ ; break ;
            case       M: file.println("static       Memory d"+(index+1)+" = Memory() ;") ;                 index++ ; break ;
            case     NOT: file.println("static          Not d"+(index+1)+" = Not() ;") ;                    index++ ; break ;
            case      JK: file.println("static           Jk d"+(index+1)+" = Jk() ;") ;                     index++ ; break ;    
            case   INPUT: file.println("static        Input d"+(index+1)+" = Input("+  pin +") ;") ;        index++ ; break ;
            case  OUTPUT: file.println("static       Output d"+(index+1)+" = Output("+  pin +") ;") ;       index++ ; break ;
            case   PULSE: file.println("static        Pulse d"+(index+1)+" = Pulse("+ time +") ;") ;        index++ ; break ;  
            case  SER_IN: file.println("static     SerialIn d"+(index+1)+" = SerialIn("+ time +") ;") ;     index++ ; break ;  
            case SER_OUT: file.println("static    SerialOut d"+(index+1)+" = SerialOut("+ time +") ;") ;    index++ ; break ;  
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
        int  in1  = block.getIn1() ;
        int  in2  = block.getIn2() ;
        int out1  = block.getOut1() ;
        int out2  = block.getOut2() ;
        
        switch( type )
        {   // analog types
            case      ANA_IN:  file.println( "static  AnalogInput a"+(index+1)+" = AnalogInput("+  pin +") ;") ;    index++ ; break ;
            case     ANA_OUT:  file.println( "static AnalogOutput a"+(index+1)+" = AnalogOutput("+  pin +") ;") ;   index++ ; break ;
            case        COMP:  file.println( "static   Comperator a"+(index+1)+" = Comperator() ;") ;               index++ ; break ;
            case       SERVO:  file.println( "static   ServoMotor a"+(index+1)+" = ServoMotor("+  pin +") ;") ;     index++ ; break ;
            case       DELAY:  file.println( "static        Delay a"+(index+1)+" = Delay("+ time +") ;") ;          index++ ; break ;
            case         MAP:  file.println( "static          Map a"+(index+1)+" = Map("+in1+","+in2+","+out1+","+out2+") ;") ;   index++ ; break ;
            case    CONSTANT:  file.println( "static     Constant a"+(index+1)+" = Constant("+time+") ;") ;         index++ ; break ;
            //case    CONSTANT:  index++ ; break ;
        }
    }
    nAnalogBlocks = index ;

    file.println("") ;
    file.println("DigitalBlock *digitalBlock[] = {") ;
    for( int i = 0 ; i < nDigitalBlocks ; i ++ ) file.println("    &d"+ (i+1)+" ,") ;
    file.println("} ;") ;
    file.println("const int nDigitalBlocks = " + nDigitalBlocks + " ;" ) ;
    file.println("") ;
    file.println("AnalogBlock *analogBlock[] = {") ;
    for( int i = 0 ; i < nAnalogBlocks ; i ++ ) file.println("    &a"+ (i+1)+" ,") ;
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
    // or for constant:  analogBlock[1] -> IN1 = 50 ;
    
        file.print("    ") ;
        if( analogIn > 0 )  file.print(" analogBlock" ) ;
        else                file.print("digitalBlock" ) ;
        file.print("["+IN+"] -> IN" +(subrow+1)+" = " ) ;

        // FunctionBlock block = blocks.get( Q ) ;         // CONST BLOCKS ARE TEMPORARILY USED AS REGULAR BLOCKS. CODE MUST BE TESTED ON BUGS NOW
        // if( block.getType() == CONSTANT )
        // {
        //     int constVal = block.getDelay() ;
        //     file.println( constVal + " ;") ;
        //     println("Q: " + Q + " CONSTANT: " + constVal ) ;

        // }
        // else
        {
            if( analogOut > 0 )  file.print(" analogBlock" ) ;
            else                 file.print("digitalBlock" ) ;
            file.println( "["+Q+"] -> Q ;") ;
        }
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
    file.println("    Serial.begin( 9600 ) ;") ;
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
/***************** SAVING, LOADING AND GENERATING SOURCE ***********/



/*
    REPEAT_MS( 500 )
    {
        Serial.println("\r\n\r\n") ;
        for( int i = 0 ; i < nDigitalBlocks ; i ++ )
        {
            int valIn1 = digitalBlock[i] -> IN1 ;
            int valIn2 = digitalBlock[i] -> IN2 ;
            int valIn3 = digitalBlock[i] -> IN3 ;
            int valQ   = digitalBlock[i] -> Q ;
            Serial.println( valIn1 ) ; 
            Serial.print( valIn2 ) ; Serial.print("         ");Serial.println( valQ) ;
            Serial.println( valIn3 ) ;Serial.println();
        } 
        Serial.println("\r\n") ;
        for( int i = 0 ; i <  nAnalogBlocks ; i ++ )
        {
            int valIn1 = analogBlock[i] -> IN1 ;
            int valIn2 = analogBlock[i] -> IN2 ;
            int valIn3 = analogBlock[i] -> IN3 ;
            int valQ   = analogBlock[i] -> Q ;
            Serial.println( valIn1 ) ; 
            Serial.print( valIn2 ) ; Serial.print("          ");Serial.println( valQ) ;
            Serial.println( valIn3 ) ;Serial.println();
            
        } 
    }
    END_REPEAT
*/	