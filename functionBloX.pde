/*
TODO
- make all test programs. MOST ARE DONE. I may do turning loop as well
- update documentation
- serial text in serial blocks, when backspace is used and characters are removed, the block itself wont update
  despite it's private variable has actually changed




NOTE:
Texts are succesfully implemented
colors are also added. May use fine tuning, but is okay for now
panning and zooming is 100% operational
besides of serial texts I can't think of any bugs. I may want to rename the 'spoof' names


BEACON

PROGRAM FUNCTIONS IN ORDE

void setup()

// ROUND ROBIN TASKS
void draw()
    drawBackground() ;
    checkFunctionBlocks() ;
    checkTexts()
    checkDemoBlocks() ;
    checkLinePoints() ;
    printTexts() ;
    updateBlocks() ;
    drawBlocks() ;
    drawLinks() ;
    drawControlButtons() ;
    updateCursor() ;
    drawCursor() ;
    printVersion() ;
    drawCheckBoxes() ;
    showMessage() ;
    com_port.draw() ;

// MOUSE EVENTS

void mousePressed()

    void leftMousePress() 
        addFunctionBlock() ;
        moveItem() ;
        alterNumber() ;
        createLink() ;
        finishLink() ;
        addNodeToLink() ;
        saveLayout() ;
        assembleProgram() ;
        flashProgram() ;
        clearProgram() ;
        alterText() ;
        handleCheckBoxes() ;

    void rightMousePress()
        void deleteObject() ;
        void deleteNode() ;
        void deleteLink() ;
        void deleteText() ;

void mouseDragged()
    void dragItem() ;
    void dragText() ;

void mouseMoved()
    dragLine() ;

void mouseReleased()
    updateLinks() ;

void mouseWheel(MouseEvent event)

// KEYBOARD EVENT
void keyPressed()

void saveLayout() ;
void loadLayout() ;
void assembleProgram() ;
void clearProgram() ;

// helper functions
void makeNumber()





*/

import java.io.BufferedReader;
import java.io.InputStreamReader; 
import java.util.concurrent.TimeUnit ;

PImage logo ;

color backGroundColor = 100 ; 
color mainPanel  = 200 ;
// color mainPanel  = #5C4033 ; dark brown 
color fbColor            = #97db61 ;
color digitalColor       = #97db61 ;
color arithmaticColor    = #db7361 ;
color digitalIoColor     = #dbb661 ;
color analogIoColor      = #618edb ;
color dccColor           = #7761db ;
color serialColor        = #bf61db ;
color miscellaneousColor = #48a186 ; // constant, pulse, comperator, delay, map
color textColor  = 0 ;

PrintWriter     file ;
PrintWriter     output;
BufferedReader  input;
PImage          mouse;

ControlButton loadButton ;
ControlButton saveButton ;
ControlButton programButton ;
ControlButton clearButton ;
ControlButton flashButton ;
ControlButton quitButton ;

// COMPORT com_port = new COMPORT(100,height-200);

String text1 = "" ;
String text2 = "" ;

String mess1 = "1" ;
String mess2 = "2" ;
String mess3 = "3" ;

ArrayList <FunctionBlock> demoBlocks = new ArrayList() ;
ArrayList <FunctionBlock>     blocks = new ArrayList() ;
ArrayList <Link>              links  = new ArrayList() ;
ArrayList <CheckBox>      checkBoxes = new ArrayList() ;
ArrayList <Text>               texts = new ArrayList() ;

final int   idle             =  0 ;
final int   movingItem       =  1 ;
final int   deletingItem     =  2 ;
final int   makingLinks      =  3 ;
final int   addingLinePoints =  4 ;
final int   settingPin       =  5 ;
final int   settingDelayTime =  6 ;
final int   settingPulseTime =  7 ;
final int   settingMapValues =  8 ;
final int   settingText      =  9 ;
final int   settingAddress   = 10 ;
final int   movingText       = 11 ;
final int   alteringText     = 12 ;

final int   defaultGridSize  = 60 ;

int         gridSize = defaultGridSize ;
int         xOffset = 0 ;
int         yOffset = 0 ;
int         selectedBoard = 255 ;

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
final int     RISING = 11 ;
final int    FALLING = 12 ;
final int        DCC = 13 ;

final int ANALOG_BLOCKS = 20 ;

final int     ANA_IN = 21 ;
final int    ANA_OUT = 22 ;
final int      SERVO = 23 ;
final int        MAP = 24 ;
final int       COMP = 25 ;
final int      DELAY = 26 ;
final int   CONSTANT = 27 ;
final int     EQUALS = 28 ;
final int   ADDITION = 29 ;
final int        SUB = 30 ;
final int        DIV = 31 ;
final int        MUL = 32 ;



// 23,5,0,0,0,0,0,  servo
// 24,0,0,0,1,30,90, map 
// 37,0,0,0,0,0,0,   
// 17,0,0,0,0,0,0,
// 22,0,0,0,0,0,0,
// 21,0,0,0,0,0,0,
// 23,6,0,0,0,0,0,


/*
checklist adding new block
- Add one to the final ints
- add demo object to the array
- alter the draw method in the class (text and connection lines)
- add redundant items, like dedicated numbers, 
- add control texts
- add device to the arduino code

*/

int     col ;
int     col_prev ;
int     col_raw ;
int     row ;
int     row_prev ;
int     row_raw ;
int     rowSpoofed ;
int     colSpoofed ;
int     subCol ;
int     subRow ;
int     spoofX ;
int     spoofY ;
int     nItems ;
boolean locked ;
int     index ;
int     mode = idle, prevMode = 255 ;
int     linkIndex = 0 ;
int     foundLinkIndex ;
int     currentType ;
int     pinNumber ;
long    delayTime ;
int     mapState ;
long    in1, in2, out1, out2 ;
int     currentAddress ;

int     linkQ ;
int     linkIn ;
int     linkRow ;
int     analogQ ;
int     analogIn ;
int     indexOfBlock ;

int     nAnalogBlocks ;
int     nDigitalBlocks ;
int     textIndex ;

String  SerialText = "";

int      hoverOverText ;
boolean  hoverOverFB ;
boolean  hoverOverDemo ;
boolean  hoverOverPoint ;
boolean  blockMiddle ;
boolean  exitFlag ;
boolean  saved ;

String   inputFile ;
String   outputFile ;
String COM_PORT = "";


void getCOMport()
{
    clearMessages() ;

    String myPath = sketchPath() ;
    String fqbn = "" ;
    String command ;
    String line ;
    String jsonData = "";
    boolean status = false ;

    // String arduinoCliPath = "C:\\Users\\Gebruiker\\Documents\\arduino-cli14\\arduino-cli.exe " ;

    String arduinoCliPath = myPath + "\\Arduino-cli\\arduino-cli.exe " ;
    String sketchPath     = myPath + "\\arduinoProgram" ;
    String listCommand    = "board list --format json" ;

    BufferedReader in ;

    try
    {
        command = arduinoCliPath + listCommand ;
        
        Process p = launch(command);
        in = new BufferedReader(new InputStreamReader( p.getInputStream()));
        while ((line = in.readLine(  )) != null) { jsonData += line ;  }

        // println( jsonData ) ;

        if (parseJSONArray(jsonData) != null)
        {
            for (int i = 0; i < parseJSONArray(jsonData).size(); i++)
            {
                if( parseJSONArray(jsonData).getJSONObject(i).getJSONObject("port").getString("protocol_label").contains("USB") )
                // NOTE, should specify this to CH340 or the main 3 original arduino boards.
                //       may also use that to auto select the right board type
                {
                    COM_PORT = parseJSONArray(jsonData).getJSONObject(i).getJSONObject("port").getString("address");
                    println( COM_PORT ) ;
                    //com_port.setNumber( number ) ;
                }
            }
        }
    } 
    catch (RuntimeException e) {println("RuntimeException, it fails") ; }
    catch (IOException e) {println("IOException, it fails") ; }
}

void settings()
{
    size(displayWidth, displayHeight) ;
}

void setup()
{ 
    selectInput("Open file", "inputSelected");
    // fullScreen() ;
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
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize, 10,  RISING, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize, 11, FALLING, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize, 12,     DCC, gridSize ) ) ;

    // RIGHT COLUMN ANALOG STUFFS
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  0,   ANA_IN, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  1,  ANA_OUT, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  2,    SERVO, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  3,      MAP, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  4,     COMP, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  5,    DELAY, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  6, CONSTANT, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  7,   EQUALS, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  8, ADDITION, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize,  9,      SUB, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize, 10,      DIV, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-1*gridSize)/gridSize, 11,      MUL, gridSize ) ) ;

    checkBoxes.add( new CheckBox(500,height-105,"MEGA") ) ;
    checkBoxes.add( new CheckBox(500,height-90,"NANO") ) ;
    checkBoxes.add( new CheckBox(500,height-75,"NANO:cpu=atmega328old") ) ;
    checkBoxes.add( new CheckBox(500,height-60,"UNO" ) ) ;

    loadButton    = new ControlButton(        10, height - 100, "LOAD" ) ;
    saveButton    = new ControlButton(       120, height - 100, "SAVE" ) ;
    programButton = new ControlButton(       230, height - 100, "MAKE\r\nPROGRAM") ;
    flashButton   = new ControlButton(       340, height - 100, "UPLOAD\r\nPROGRAM") ;
    //clearButton   = new ControlButton(       450, height - 100, "CLEAR") ;
    quitButton    = new ControlButton( width-110, height - 100, "QUIT") ;

    logo = loadImage("Train-Science.png") ;

    getCOMport() ;
}

void draw()
{
    drawBackground() ;
    checkFunctionBlocks() ;
    checkTexts() ;
    drawBlocks() ;
    drawLinks() ;
    checkDemoBlocks() ;
    checkLinePoints() ;
    printTexts() ;
    updateBlocks() ;
    drawControlButtons() ;
    updateCursor() ;
    drawCursor() ;
    drawCheckBoxes() ;
    showMessage() ;
    showComPort() ;
    drawTexts() ;

    showLogo() ;
    printVersion() ;

    if( mode != prevMode )
    {
        // debug stuff was here
        prevMode = mode ;
    }


}

void drawBackground()
{
    // background(0x9b,0x87,0x0c) ; backGroundColor = 0xAb970c ;
    background( backGroundColor  ) ; // dark grey main window

    fill( mainPanel) ;
    rect(5,5,(width - 2*defaultGridSize) - 2 , (height - 2*defaultGridSize) - 2 ) ; // canvas

    textAlign(CENTER,CENTER);
    for( int i = 0 ; i < demoBlocks.size() ; i ++ )
    {
        FunctionBlock block = demoBlocks.get(i) ;
        block.draw() ;
    }
}

void drawControlButtons()
{
    text1 = "" ;
    textSize(30);  
    saveButton.draw() ;
    loadButton.draw() ;
    programButton.draw() ;
    flashButton.draw() ;
    //clearButton.draw() ;
    quitButton.draw() ;
    textSize(30);  
    textAlign(RIGHT,TOP);
    text( text1,  width/2 - defaultGridSize, 10 ) ;
}

void updateBlocks()
{
    int analogIndex  = 0 ;
    int digitalIndex = 0 ;
    for( int i = 0 ; i < blocks.size() ; i++ ) 
    {
        FunctionBlock block = blocks.get(i) ;
        int type = block.getType() ;
        if( type >= ANA_IN ) { block.setIndex(  analogIndex ++ ) ; }
        else                 { block.setIndex( digitalIndex ++ ) ; }
    }
}

void updateLinks()
{
    for( int i = 0 ; i < links.size() ; i++ )  // get connected Q of the link
    {
        Link link = links.get( i ) ; // NOTE IndexOutOfBoundsException has occured once 11-3-2024

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
        
        if( colSpoofed == (block.getXpos() ) 
        &&  rowSpoofed == (block.getYpos() ) )
        {
            hoverOverFB = true ;
            if( subCol == 1 && subRow == 1 ) blockMiddle =  true ;
            index = i ;
            indexOfBlock = block.getIndex() ;
            return ;
        }
    }
}

void checkTexts()
{
    if( mode == movingItem ) return ;

    for (int i = 0; i < texts.size(); i++)                                     // loop over all function blocks, sets index according and sets or clears 'hoverOverFB'
    { 
        hoverOverText = 0 ;

        Text description = texts.get(i);
        if( description.hoveringOver() > 0 )
        {
            hoverOverText = description.hoveringOver() ;                        // 1 is hovering over move control, 2 is hovering over text control
            textIndex = i ;
            return ;
        }
    }
}

void checkDemoBlocks()
{
    if( mode == movingItem ) return ;

    for (int i = 0; i < demoBlocks.size(); i++)                                     // loop over all function blocks, sets index according and sets or clears 'hoverOverFB'
    { 
        hoverOverDemo = false ;

        FunctionBlock block = demoBlocks.get(i);

        block.lock() ;
        
        if( col_raw == block.getXpos() 
        &&  row_raw == block.getYpos() )
        {
            hoverOverDemo = true ;
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
            if( link.getPosX( j ) == colSpoofed      //text("col: true",10,230);
            &&  link.getPosY( j ) == rowSpoofed      //text("row: true",10,250);
            &&  link.getSubX( j ) == subCol   //text("subCol: true" ,10,270); 
            &&  link.getSubY( j ) == subRow ) //text("subRow: true" ,10,290);
            {   
                hoverOverPoint = true ;
                return ;
            }
        }
    }
    //foundLinkIndex = 0 ;
}

void updateCursor()
{
    // SK find some method to prevent drawing boxes were it should not during zooming out
    // spoofing mouse values is FUBAR for panning. The blocks and links have to be phyiscally placed at different coordinates.

    col_raw = mouseX / defaultGridSize ;

    col = mouseX / gridSize ;
    int max_col = (width - 3*gridSize) / gridSize ;
    col = constrain( col, 0, max_col ) ;
    colSpoofed = col - xOffset ;

    row_raw =    mouseY / defaultGridSize ;

    row =    mouseY / gridSize  ;
    int max_row = (height - 3*gridSize ) / gridSize ;
    row = constrain( row, 0, max_row ) ;
    rowSpoofed = row - yOffset ;


    if( mode != movingItem )
    {
        subCol = mouseX / (gridSize/3) % 3 ; // NOTE this suck balls when the gridSize is not divisable by 3
        subRow = mouseY / (gridSize/3) % 3 ;
    }  
   

    // textAlign(LEFT,TOP);
    // textSize(20);    
    // text("col: " + col,10,50);                                                         // row and col on screen.
    // text("row: " + row,10,70);
    // text("index: "+ index,10,90);  text("index2: "+ indexOfBlock,200,90);
    // text("mode " + mode,10,110);
    // text("subCol " + subCol,10,130);
    // text("subRow " + subRow,10,150);
    // if(hoverOverPoint == true ) text("line detected ",10,170);
    // text("linkQ   " + linkQ, 10, 190);
    // text("linkIn  " + linkIn, 10, 210);
    // text("linkRow " + linkRow, 10, 230);
    // text("analogQ " + analogQ, 10, 250);
    // text("analogIn " + analogIn, 10, 270);
    // text("link index " + foundLinkIndex, 10, 290);
    // // text("X offset " + xO f fset, 10, 310);
    // // text("Y offset " + yO f fset, 10, 330);
    // text("hoverOverDemo " + hoverOverDemo, 10, 350);
    // text("col spoof: " + colSpoofed,10,370);                                                         // row and col on screen.
    // text("row spoof: " + rowSpoofed,10,390);
    // text("grid size: " + gridSize,10,410);

    // if( text1 != "" || text2 != "" )
    // {
    //     fill(255) ;
    //     arc(mouseX, mouseY, 10, 10, 0, 2*PI );
    // }
    fill(0);

}

void printTexts()
{
    try
    { 
        fill(0);
        FunctionBlock block = blocks.get(index);

        int type = block.getType() ;
        SerialText = block.getText() ;
        
        try{
            Text description    =  texts.get( textIndex ) ;
            if( mode == alteringText )
            {
                SerialText = description.getDescription() ;
            }
        }
        catch (IndexOutOfBoundsException e) {}

        if( SerialText      == null ) SerialText = "" ;

        text1 = "";
        text2 = "";
        mouse = loadImage("images/mouse1.png") ;

        if(mouseX > (width-2*gridSize) 
        && hoverOverDemo  
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
        else if( mode == movingText )
        {
            text1 = "MOVING TEXT" ;
            text2 = "" ;
        }
        else if( mode == settingPin )
        {
            text1 = "SET PIN NUMBER: " + pinNumber ;
            text2 = "PRESS <ENTER> WHEN READY" ;
        }
        else if( mode == settingDelayTime )
        {
            text1 = "ENTER DELAY TIME: " + delayTime ;
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
            else if( type == DCC )
            {
                text1 = "SET DCC ADDRESS" ;
                text2 = "" ;
            }
            else if( type == SER_IN || type == SER_OUT )
            {
                text1 = "ENTER MESSAGE" ;
                text2 = SerialText ;
            }
        }
        else if( mode == settingText )
        {
            text1 = "ENTER MESSAGE" ;
            text2 = SerialText ;
        }
        else if( mode == alteringText )
        {
            text1 = "Alter text: " + SerialText ;
            text2 = "PRESS <ENTER> WHEN READY" ;
        }
        else if( mode == settingAddress )
        {
            text1 = "ENTER ADDRESS" ;
            text2 = "" ;
        }
        else if( mode == settingPulseTime )
        {
            text1 = "ENTER PULSE SWITCH TIME: " + delayTime ;
            text2 = "PRESS <ENTER> WHEN READY" ;
        }
        else if( mode == settingMapValues )
        {
            switch( mapState )
            {
                case 0: text1 = "SET IN 1: "  +  in1 ; break ;
                case 1: text1 = "SET IN 2: "  +  in2 ; break ;
                case 2: text1 = "SET OUT 1: " + out1 ; break ;
                case 3: text1 = "SET OUT 2: " + out2 ; break ;
            }
            text2 = "PRESS <ENTER> WHEN READY" ;
        }
        else if(    loadButton.hoveringOver() )    {text1 = "LOAD PROGRAM" ;}
        else if(    saveButton.hoveringOver() )    {text1 = "SAVE PROGRAM" ;}
        else if( programButton.hoveringOver() )    {text1 = "ASSEMBLE PROGRAM" ;}
        else if(   flashButton.hoveringOver() )    {text1 = "FLASH PROGRAM" ;}
       // else if( clearButton.hoveringOver() )      {text1 = "CLEAR PROGRAM" ;}
        else if(    quitButton.hoveringOver() )    {text1 = "SAVE AND QUIT PROGRAM" ;}
        else if(  hoverOverText == 1 )             {text1 = "MOVE TEXT AROUND" ; text2 = "DELETE TEXT" ; }
        else if(  hoverOverText == 2 )             {text1 = "CHANGE TEXT" ;}


        if(      text1 == "" && text2 != "" ) mouse = loadImage("images/mouse4.png") ;
        else if( text1 != "" && text2 == "" ) mouse = loadImage("images/mouse2.png") ;
        else if( text1 != "" && text2 != "" ) mouse = loadImage("images/mouse3.png") ;
        else                                  mouse = loadImage("images/mouse1.png") ;

        if( mode != settingText ) image(mouse, width/2-defaultGridSize, defaultGridSize/5,defaultGridSize,defaultGridSize);
        textSize(30);  
        textAlign(RIGHT,TOP);
        text( text1,  width/2 - defaultGridSize, 10 ) ;
        textAlign(LEFT,TOP);
        text( text2, width/2, 10 ) ;
        textAlign(CENTER,CENTER);
    }
    catch (IndexOutOfBoundsException e) {}
}


// mouse PRESSED FUNCTIONS
void addFunctionBlock()
{
    int row =    mouseY / defaultGridSize ;
    mode = movingItem ;

    if( mouseX > (width-defaultGridSize)) currentType = row + 21 ; // hover over analog things
    else                                  currentType = row +  1 ; // hover over digital things

    pinNumber = 0 ;

    blocks.add( new FunctionBlock(( width- 3*defaultGridSize) / defaultGridSize, row, currentType, defaultGridSize )) ;    

    index = blocks.size() - 1 ;
}

void moveItem()
{
    try
    {
        FunctionBlock block = blocks.get( index ); // DEBUG NEED A TRY N CATCH.. 3x happened

        if( colSpoofed == block.getXpos() &&  rowSpoofed == block.getYpos() && blockMiddle == true )
        {
            mode = movingItem ;
        }
    }
    catch( IndexOutOfBoundsException e ) {}
}

void alterText()
{
    try
    {
        Text description ;

        for (int i = 0; i < texts.size(); i++) // find out index of text
        {
            description = texts.get( i ) ;
            if( description.hoveringOver() > 0 ) 
            {
                if( description.hoveringOver() == 1 ) mode = movingText ;
                if( description.hoveringOver() == 2 ) mode = alteringText ;

                textIndex = i ;
                println( textIndex ) ; 
                break ; 
            }
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
        in1 = in2 = out1 = out2 = 0 ;
        SerialText = "" ;

        FunctionBlock block = blocks.get( index ) ;
        int type = block.getType() ;

        if( type ==   DELAY 
        ||  type == CONSTANT) mode = settingDelayTime ;

        if( type ==   PULSE ) mode = settingPulseTime ;

        if( type ==     MAP ) mode = settingMapValues ;

        if( type ==  SER_IN
        ||  type == SER_OUT ) mode = settingText ;

        if( type == DCC )     {mode = settingAddress ;/* println("setting DCC address") ;*/}

        if( type ==   INPUT
        ||  type ==  OUTPUT
        ||  type ==  ANA_IN
        ||  type ==   SERVO
        ||  type == ANA_OUT ) mode = settingPin ;

        return ;


    } catch (IndexOutOfBoundsException e) {}

    // try TODO ADDTEXTS
    // {


    //     Text description = texts.get( index ) ;


    //     return ;


    // } catch (IndexOutOfBoundsException e) {}
}

void createLink()
{
    mode = addingLinePoints ;

    int analogIO = 0 ;

    FunctionBlock block = blocks.get( index ) ;
    int type = block.getType() ;

    linkIndex = links.size()  ;

    links.add( new Link( colSpoofed, rowSpoofed, gridSize ) ) ;
    Link link = links.get( linkIndex ) ;            // ERROR IF first a link is removed than a new one is adde, we get an error out of bounds.
    link.updatePoint( colSpoofed, rowSpoofed, subCol, subRow  ) ;
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
    link.updatePoint( colSpoofed, rowSpoofed, subCol, subRow  ) ;
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

void deleteNode()
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

void deleteLink()
{
    println("foundLinkIndex: " + foundLinkIndex) ;
    if( foundLinkIndex >= 0 )
    {
        links.remove( foundLinkIndex ) ;
        foundLinkIndex -- ;
    }
}

void deleteText()
{
    if( textIndex >= 0 )
    {
        texts.remove( textIndex ) ;
        textIndex -- ;
    }
}

void dragItem() 
{
    FunctionBlock block = blocks.get(index);
    block.setPos( colSpoofed, rowSpoofed ); // these offsets work...
}

void dragText()
{
    Text description = texts.get( textIndex ) ;
    description.move( colSpoofed, rowSpoofed ) ;
}

void dragLine()
{
    Link link = links.get( linkIndex ) ;
    link.updatePoint( colSpoofed, rowSpoofed, subCol, subRow  ) ;
}

void drawCursor()
{
    int x = (col) * gridSize + subCol * gridSize / 3 + gridSize/6 ;
    int y = (row) * gridSize + subRow * gridSize / 3 + gridSize/6 ;

    line(0,y,width,y) ;
    line(x, 0, x, height) ;
}
// helper functions


void leftMousePress()
{
    if( mode == settingPin || mode == settingDelayTime || mode == settingPulseTime 
    ||  mode == settingMapValues || mode == settingText || mode == settingAddress ) mode = idle ; // as long as a number is set, LMB nor RMB must do anything

    if(      mode == idle && hoverOverDemo )                                     addFunctionBlock() ;
    else if( mode == idle )                                                      moveItem() ;
    if (     mode == idle && subCol == 1 && subRow == 2 && hoverOverFB == true ) alterNumber() ;
    else if( mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true ) createLink() ; // N.B. create link from !Q ? 
    else if( mode == addingLinePoints && subCol == 0    && hoverOverFB == true ) finishLink() ;
    else if( mode == addingLinePoints )                                          addNodeToLink() ;
    else if( loadButton.hoveringOver() )                                         selectInput("Open file", "inputSelected");
    else if( saveButton.hoveringOver() )                                         selectOutput("Save file", "outputSelected");
    else if( programButton.hoveringOver() )                                      assembleProgram() ; // obsolete?
    else if(   flashButton.hoveringOver() )                                    { assembleProgram() ;
                                                                                 flashProgram() ; }
    else if( hoverOverText > 0 )                                                 alterText() ;
    //else if( clearButton.hoveringOver() )                                        clearProgram() ;
    else if( quitButton.hoveringOver() )                                        
    { 
        assembleProgram() ;
        if( saved == true) exit() ; 
        else
        {
            exitFlag = true ;
            selectOutput("Save file", "outputSelected");
        }
    }
    else
    {
        handleCheckBoxes() ;
    }

}

void rightMousePress()
{
    if( mode == settingPin ) return ;                                        // as long as a number is set, LMB nor RMB must do anything

    if( mode == idle 
    && blocks.size() > 0 
    &&  index < blocks.size() 
    && hoverOverFB == true
    && blockMiddle == true )                deleteObject() ;  
    else if( mode == addingLinePoints )     deleteNode() ;
    else if( hoverOverPoint )               deleteLink() ;
    else if( hoverOverText == 1 )           deleteText() ;
}
void mousePressed()
{	
    if( mouseButton ==  LEFT )              leftMousePress() ;
    if( mouseButton == RIGHT )              rightMousePress() ;
    saved = false ;
}
void mouseDragged()
{
    if( mouseButton ==  LEFT 
    &&  mode == movingItem )                dragItem() ;

    if( mouseButton == LEFT
    &&  mode == movingText )                dragText() ;

    if( mouseButton ==  CENTER )        // spoof mouse values in order to achieve panning
    {
        if( row != row_prev || col != col_prev)
        {
            int toChange = (120-gridSize)/30+1;

            if( row < row_prev ) yOffset -= toChange ;
            if( row > row_prev ) yOffset += toChange ;

            if( col < col_prev ) xOffset -= toChange ;
            if( col > col_prev ) xOffset += toChange ;
                
            row_prev = row ;   col_prev = col ;
        }
    }
}
void mouseMoved()
{
    if( mode == addingLinePoints )          dragLine() ;

    if( row != row_prev || col != col_prev)
    {   row_prev = row ;   col_prev = col ; }
}
void mouseReleased()
{
    if( mode == movingItem || mode == movingText )
    {
        mode = idle ;
    }
}

void mouseWheel(MouseEvent event)
{
    float e = event.getCount();
    if(( e > 0 && gridSize <  45 )
    || ( e < 0 && gridSize > 105 )) return ;
    gridSize -= 15* (int) e ;
}



long makeNumber(long _number, long lowerLimit, long upperLimit )
{
         if( keyCode ==  LEFT      ) { _number -- ;             }
    else if( keyCode == RIGHT      ) { _number ++ ;             }
    else if( _number == upperLimit ) { _number = ( key-'0' ) ;  }
    else if( keyCode == BACKSPACE  ) { _number /= 10 ;          }
    else if( key >= '0' && key <= '9') 
    {
        _number *= 10;
        _number += ( key-'0' );
    }
    //float temp = (long)constrain(_number,lowerLimit,upperLimit);   
    _number = (long)constrain(_number,lowerLimit,upperLimit);   
    //println(_number);    
    return _number;
}

void keyPressed()
{
    // PRINT LINKS FOR DEBUGGING
    if (key == ESC) 
    {
        key = 0 ;           // discard escape key, prevents accidently terminating and lose things..
        mode = idle ;
    }
    
    println("mode: " + mode ) ;
    if( mode == settingPin       || mode == settingDelayTime 
    ||  mode == settingPulseTime || mode == settingMapValues 
    /*||  mode == settingText  */|| mode == settingAddress    )
    {
        if( keyCode == ENTER )
        {
            if( mode == settingMapValues )
            {
                if( ++ mapState == 4 ) mapState = 0 ; // handles the four numbers in a map block
                else return ;
            }
            delayTime = currentAddress = pinNumber = 0 ; // reset working variables.
            mode = idle ;
            return ;
        }
        else
        {
            FunctionBlock block = blocks.get( index ) ;
            if( mode == settingPin )
            {
                pinNumber = (int)makeNumber( (int)pinNumber, 0, 31) ;
                block.setPin( pinNumber ) ;
                if( key == 'a') block.setPinType( 1 ) ; 
                if( key == 'd') block.setPinType( 0 ) ; 
            }
            else if( mode == settingAddress )
            {
                currentAddress = (int)makeNumber( currentAddress, 0, 2048 ) ;
                block.setAddress( currentAddress ) ;
            }
            else if( mode == settingMapValues )
            {
                switch( mapState )
                {
                    case 0: in1  = makeNumber(  in1, 0, 4300000000L ) ;block.setIn1( in1) ; break ; // more than large enough
                    case 1: in2  = makeNumber(  in2, 0, 4300000000L ) ;block.setIn2( in2) ; break ;
                    case 2: out1 = makeNumber( out1, 0, 4300000000L ) ;block.setOut1(out1) ; break ;
                    case 3: out2 = makeNumber( out2, 0, 4300000000L ) ;block.setOut2(out2) ; break ;
                }
            }
            else
            {
                delayTime = makeNumber( delayTime, 0, 4300000000L ) ;
                block.setDelay( delayTime ) ; // used for delay and pulse generator
            }
        }
    }
    else if( mode == settingText || mode == alteringText ) // the first is for serial blocks, the other for text elements
    {
        println("altering") ;
        if( keyCode == BACKSPACE 
        &&  SerialText.length() > 0 )
        {
            SerialText = SerialText.substring( 0, SerialText.length()-1 ); 
        }
        else if( keyCode == ENTER )
        {
            mode = idle ;
        }
        else if( key >= 20 && key <= 128 )
        {
            SerialText += key ;
        }

        if( mode == settingText )
        {
            FunctionBlock block = blocks.get( index ) ;
            println("setting texts: " + SerialText) ;
            println("index: "+index) ;
            block.setText( SerialText ) ;
        }
        if( mode == alteringText )
        {
            Text description = texts.get( textIndex ) ;
            description.setDescription( SerialText ) ;
        }
    }

    else if( key == 't' )
    {
        println("adding text");
        texts.add( new Text( colSpoofed, rowSpoofed, "text" )) ;
        saved = false ;
    }
    else if( key == ' ' )
    {
        xOffset = yOffset = 0 ;
    }
}


void outputSelected( File output ) 
{
    outputFile = output.getAbsolutePath() ;
    println( outputFile ) ;

    saveLayout() ;

    saved = true ;

    if( exitFlag == true ) exit() ;
}

/***************** SAVING, LOADING AND GENERATING SOURCE ***********/
void saveLayout()
{
    
    //println("LAYOUT SAVED");

    output = createWriter( outputFile ) ;

    output.println( blocks.size() ) ;          // the amount of elements is saved first, this is used for the loading

    for (int i = 0; i < blocks.size() ; i++ ) // SK: BUG sometimes false entry of some non existing block... (still relevant?)
    {
        FunctionBlock block = blocks.get(i) ;
        output.println( block.getXpos() + "," + block.getYpos() + "," 
                      + block.getType() + "," + block.getPin()  + "," 
                      + block.getDelay()+ "," 
                      + block.getIn1()  + "," + block.getIn2()  + "," 
                      + block.getOut1() + "," + block.getOut2() + ","
                      + block.getText() + ","
                      + block.getAddress() + ","
                      + block.getPinType() ) ;
    }

    output.println(links.size());           // LINKS
    for (int i = 0; i < links.size(); i++ )
    {
        Link link = links.get(i) ;
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
        
        //output.println() ;  // newline
    } 

    output.println(texts.size());  // TEXTS
    for (int i = 0; i < texts.size(); i++ )
    {
        Text description = texts.get(i) ;
        output.println( description.getX() + "," + description.getY() + "," + description.getDescription() ) ;
    }

    output.close();
}

void inputSelected(File selection)
{
    inputFile = selection.getPath() ;
    clearProgram() ;
    loadLayout() ;
}

void loadLayout()
{
    //println("LAYOUT LOADED");
    String line = "" ;

    try
    {
        input = createReader( inputFile ); 
        line = input.readLine();
    } 
    catch (IOException e) { return ;}
    catch (NullPointerException e ) {return ;}
    
    int size = Integer.parseInt(line) ;
    
    for( int j = 0 ; j < size ; j++ )
    {
        try { line = input.readLine(); } 
        catch (IOException e) {return ;}
        
        String[] pieces = split(line, ',');
        int       dataLen = pieces.length ;
        int X     = Integer.parseInt( pieces[0] ) ;
        int Y     = Integer.parseInt( pieces[1] ) ;
        int type  = Integer.parseInt( pieces[2] ) ;
        int  pin  = Integer.parseInt( pieces[3] ) ;
        int time  = Integer.parseInt( pieces[4] ) ;
        int  in1  = Integer.parseInt( pieces[5] ) ;
        int  in2  = Integer.parseInt( pieces[6] ) ;
        int out1  = Integer.parseInt( pieces[7] ) ;
        int out2  = Integer.parseInt( pieces[8] ) ;
        String message =              pieces[9]   ;
        int addr = 0 ;
        if( dataLen > 10 ) {    addr  = Integer.parseInt( pieces[10] ) ; }

        int pinType = 0 ;
        if( dataLen > 11 ) { pinType  = Integer.parseInt( pieces[11] ) ; }


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
        block.setText( message ) ;
        block.setAddress( addr ) ;
        block.setPinType( pinType ) ;
    } 

    try { line = input.readLine(); } 
    catch (IOException e) {}

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
    
    size = 0 ;
    try { 
        line = input.readLine();
        size = Integer.parseInt( line ) ;

        for( int i = 0 ; i < size ; i++ )   // SEEM TO WORK
        {
            line = input.readLine();
            String[] pieces = split(line, ',');
            int x = Integer.parseInt( pieces[0] ) ;
            int y = Integer.parseInt( pieces[1] ) ;
            String description =      pieces[2] ;

            texts.add( new Text(x,y,description)) ;
            //println("added text: "+description+" At pos("+x+','+y+')');
        }    
    } 
    catch (IOException e) { println("NO TEXTS IN FILE"); }

    saved = true ;
}

void clearProgram()
{
    for( int i = blocks.size() ; i > 0 ; i -- )
    {
        blocks.remove(i-1);
    }
    for( int i = links.size() ; i > 0 ; i -- )
    {
        links.remove(i-1);
    }
    for( int i = texts.size() ; i > 0 ; i -- )
    {
        texts.remove(i-1);
    }
    linkIndex = 0 ;
}

void assembleProgram() 
{    
    updateLinks() ;

    file = createWriter("arduinoProgram/arduinoProgram.ino");
    file.println("#include \"functionBlocks.h\"") ;
    file.println("") ;
    int index = 0 ;

    int nDigitalBlocks ;
    int nAnalogBlocks ;

    for( int i = 0 ; i < blocks.size() ; i ++ )     // store digital components
    {
        FunctionBlock block = blocks.get( i ) ;
        int       type = block.getType() ;
        long      time = block.getDelay() ;
        int  pinNumber = block.getPin() ;
        int    pinType = block.getPinType() ;
        String IO = str( pinNumber ) ;
        if( pinType == 1 ) IO = "A" + str( pinNumber ) ;
        String    mess = block.getText() ;
        int    address = block.getAddress() ;

        // Add code to keep track of servo objects, their indices need to be stored
        
        switch( type )
        {   // digital types
            case     AND: file.println("static          And d"+(index+1)+" = And() ;") ;                    index++ ; break ;
            case      OR: file.println("static           Or d"+(index+1)+" = Or() ;") ;                     index++ ; break ;
            case       M: file.println("static       Memory d"+(index+1)+" = Memory() ;") ;                 index++ ; break ;
            case     NOT: file.println("static          Not d"+(index+1)+" = Not() ;") ;                    index++ ; break ;
            case      JK: file.println("static           Jk d"+(index+1)+" = Jk() ;") ;                     index++ ; break ;    
            case   INPUT: file.println("static        Input d"+(index+1)+" = Input("+  IO +") ;") ;         index++ ; break ;
            case  OUTPUT: file.println("static       Output d"+(index+1)+" = Output("+  IO +") ;") ;        index++ ; break ;
            case   PULSE: file.println("static        Pulse d"+(index+1)+" = Pulse("+ time +") ;") ;        index++ ; break ;  
            case  SER_IN: file.println("static     SerialIn d"+(index+1)+" = SerialIn( \""+ mess +"\") ;") ;index++ ; break ;  
            case SER_OUT: file.println("static    SerialOut d"+(index+1)+" = SerialOut(\""+ mess +"\") ;") ;index++ ; break ;  
            case  RISING: file.println("static       Rising d"+(index+1)+" = Rising()  ;") ;                index++ ; break ;  
            case FALLING: file.println("static      Falling d"+(index+1)+" = Falling() ;") ;                index++ ; break ;
            case     DCC: file.println("static          DCC d"+(index+1)+" = DCC("+ address +") ; " ) ;     index++ ; break ;
        }
    }
    nDigitalBlocks = index ; 

    index = 0 ;
    for( int i = 0 ; i < blocks.size() ; i ++ )  // store analog components
    {
        FunctionBlock block = blocks.get( i ) ;
        int  type  = block.getType() ;
        long time  = block.getDelay() ;
        int   pin  = block.getPin() ;
        long  in1  = block.getIn1() ;
        long  in2  = block.getIn2() ;
        long out1  = block.getOut1() ;
        long out2  = block.getOut2() ;
        
        switch( type )
        {   // analog types
            case      ANA_IN:  file.println( "static  AnalogInput a"+(index+1)+" = AnalogInput("+  pin +") ;") ;    index++ ; break ;
            case     ANA_OUT:  file.println( "static AnalogOutput a"+(index+1)+" = AnalogOutput("+  pin +") ;") ;   index++ ; break ;
            case        COMP:  file.println( "static   Comperator a"+(index+1)+" = Comperator() ;") ;               index++ ; break ;
            case       SERVO:  file.println( "static   ServoMotor a"+(index+1)+" = ServoMotor("+  pin +") ;") ;     index++ ; break ;
            case       DELAY:  file.println( "static        Delay a"+(index+1)+" = Delay("+ time +") ;") ;          index++ ; break ;
            case         MAP:  file.println( "static          Map a"+(index+1)+" = Map("+in1+","+in2+","+out1+","+out2+") ;") ;   index++ ; break ;
            case    CONSTANT:  file.println( "static     Constant a"+(index+1)+" = Constant("+time+") ;") ;         index++ ; break ;
            case      EQUALS:  file.println( "static       Equals a"+(index+1)+" = Equals() ;") ;                   index++ ; break ;
            case    ADDITION:  file.println( "static          Add a"+(index+1)+" = Add() ;") ;                      index++ ; break ;
            case         SUB:  file.println( "static          Sub a"+(index+1)+" = Sub() ;") ;                      index++ ; break ;
            case         MUL:  file.println( "static          Mul a"+(index+1)+" = Mul() ;") ;                      index++ ; break ;
            case         DIV:  file.println( "static          Div a"+(index+1)+" = Div() ;") ;                      index++ ; break ;
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
        Link    link = links.get( i ) ;
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
    file.println("#include \"NmraDcc.h\"") ;
    file.println("NmraDcc dcc ;") ;
    file.println("uint16_t lastSetAddress ;") ;
    file.println("uint8_t  lastSetState ;") ;
    file.println("") ;
    file.println("void notifyDccAccTurnoutOutput ( uint16_t Addr, uint8_t Direction, uint8_t OutputPower ) // called from DCC lib") ;
    file.println("{") ;
    file.println("    lastSetAddress = Addr ;") ;
    file.println("    lastSetState   = Direction ;") ;
    file.println("    if( lastSetState > 1 ) lastSetState = 1 ;") ;
    file.println("}") ;
    file.println("") ;
    file.println("uint8_t getDCCstate( uint16_t address ) // called by DCC function blox") ;
    file.println("{") ;
    file.println("    if( address != lastSetAddress ) return 2 ;") ;
    file.println("    else return lastSetState ;") ;
    file.println("}") ;
    file.println("") ;
    file.println("void sendMessage( String S )") ;
    file.println("{") ;
    file.println("    Serial.println( S ) ;") ;
    file.println("}") ;
    file.println("") ;
    file.println("String getMessage()") ;
    file.println("{") ;
    file.println("    static String lastMessage ;") ;
    file.println("    static bool messReceived = true ;") ;
    file.println("") ;
    file.println("    if( Serial.available() )") ;
    file.println("    {    ") ;
    file.println("        if( messReceived )") ;
    file.println("        {   messReceived = false ;") ;
    file.println("") ;
    file.println("            lastMessage = \"\" ;") ;
    file.println("        }") ;
    file.println("        char c = Serial.read() ;") ;
    file.println("        if( c == '\\n')") ;
    file.println("        {") ;
    file.println("            messReceived = true ;") ;
    file.println("        }") ;
    file.println("        else if( c >= ' ' )   // discard all non printable characters except newline") ;
    file.println("        {") ;
    file.println("            lastMessage += c ;") ;
    file.println("        }") ;
    file.println("    }") ;
    file.println("    return lastMessage ;") ;
    file.println("}") ;
    file.println("") ;
    file.println("void setup()") ;
    file.println("{") ;
    file.println("    Serial.begin( 115200 ) ;") ;
    file.println("    dcc.init( MAN_ID_DIY, 10, CV29_ACCESSORY_DECODER | CV29_OUTPUT_ADDRESS_MODE, 0 );") ;
    file.println("}") ;
    file.println("") ;
    file.println("void loop()") ;
    file.println("{") ;
    file.println("    dcc.process() ;") ;
    file.println("/***************** UPDATE FUNCTION BLOCKS *****************/") ;
    file.println("    for( int i = 0 ; i < nDigitalBlocks ; i ++ ) { digitalBlock[i] -> run() ; updateLinks() ; }") ;
    file.println("    for( int i = 0 ; i <  nAnalogBlocks ; i ++ ) {  analogBlock[i] -> run() ; updateLinks() ; }") ;
    file.println("}") ;
    file.close() ;
}

/* IDEAS FOR HARDWARE
CURRENT DETECT

TODO:
  make functions for compiling and uploading alike.

*/
void flashProgram()
{
    clearMessages() ;

    getCOMport() ;

    assembleProgram() ;

    String myPath = sketchPath() ;
    String fqbn = "" ;
    String command ;
    String line ;
    String jsonData = "";
    boolean status = false ;

    // String arduinoCliPath = "C:\\Users\\Gebruiker\\Documents\\arduino-cli14\\arduino-cli.exe " ;
    String arduinoCliPath = myPath + "\\Arduino-cli\\arduino-cli.exe " ;
    String sketchPath     = myPath + "\\arduinoProgram" ;

    BufferedReader in ;

    if( selectedBoard == 255 ) { setMessage(1,"no board selected"); return ; }

    CheckBox box = checkBoxes.get(selectedBoard) ; // get FQBN from selected board..
    fqbn = "arduino:avr:" + box.getName() ;
    
    String buildCommand   = "compile -b " + fqbn + " " + sketchPath ;
    String uploadCommand  = "upload " + sketchPath + " -b " + fqbn + " -p "+ COM_PORT ;

    println("buildCommand:  ",buildCommand) ;
    println("uploadCommand: ",uploadCommand) ;

    try
    {      
        command = arduinoCliPath + buildCommand ; // compile (can't toss errors really..)
        println(command);
        Process p = launch(command);

        command = arduinoCliPath + uploadCommand ; // start upload
        println(command);
        p = launch(command);
        //if(!p.waitFor(10, TimeUnit.SECONDS)) { p.destroy();  }

        in = new BufferedReader(new InputStreamReader( p.getInputStream())); // extra debug stuff
        while ((line = in.readLine(  )) != null)
        {
            if( line.contains("New upload port")) status = true ; // this particular text comes by when an upload is succesful
        }
        if( status == true )  { println("SUCCES") ; }
        else                  { println("FAILED") ; }
    } 
    catch (RuntimeException e) {println("RuntimeException, it fails") ; }
    catch (IOException e) {println("IOException, it fails") ; }
    //catch (InterruptedException e) {println("FAILED") ; }
}
/* steps: 
- check if we are atleast hovering about one of boxes
- remember which one was high
- force all states to zero
- 

*/
void handleCheckBoxes()
{
    int index = 255 ;
    for (int i = 0; i < checkBoxes.size(); i++) 
    {
        CheckBox box = checkBoxes.get(i) ;
        
        if( box.hoveringOver() )
        {
            index = i ;
            break ;
        }
    }

    if( index != 255 ) // if one box is clicked, deselect all boards
    {
        for (int i = 0; i < checkBoxes.size(); i++) 
        {
            CheckBox box = checkBoxes.get(i) ;
            box.setState( 0 ) ;
        }

        CheckBox box = checkBoxes.get( index ) ;
        box.setState( 1 ) ;                 // and selected the clicked box

        selectedBoard = index ;
    }
}


void drawCheckBoxes()
{
    fill(0) ;
    textSize(15);
    //text("BOARD",470,height-110) ;

    for (int i = 0; i < checkBoxes.size(); i++)                                     // loop over all function blocks, sets index according and sets or clears 'hoverOverFB'
    { 
        CheckBox box = checkBoxes.get(i) ;
        box.draw() ;
    }
}

void showMessage()
{
    stroke(0);
    fill(255);

    rect(width-650,height - 100, 430, 90);

    textSize(15);
    fill(0);
    text( mess1, width-640, height-90 ) ;
    text( mess2, width-640, height-73 ) ;
    text( mess3, width-640, height-56 ) ;
}

void setMessage( int id, String text2be )
{
    switch( id ) 
    {
        case 1 : mess1 = text2be ; break ;
        case 2 : mess2 = text2be ; break ;
        case 3 : mess3 = text2be ; break ;
    }

    showMessage() ; // force an update after //setMessage due to blocking processes
}

void clearMessages()
{
    setMessage(1,"") ;
    setMessage(2,"") ;
    setMessage(3,"") ;

    showMessage() ;
}

void showComPort()
{
    textSize(20);
    fill(0) ;
    if( COM_PORT != "" ) text( "Found port: " + COM_PORT, 580, height-100 ) ;
    else                 text( "No port found", 580, height-100 ) ;
}

void drawTexts()
{
    for (int i = 0; i < texts.size(); i++)                                     // loop over all function blocks, sets index according and sets or clears 'hoverOverFB'
    { 
        Text description = texts.get(i) ;
        description.draw() ;
    } 
}

void showLogo()
{
    textSize(30);
    fill(0);
    textAlign(CENTER,BOTTOM);
    text("FunctionBloX", width/2, height - 80) ;

    image(logo, width/2 + 100, height-110, 70, 70);
}

void printVersion() { text("V1.2.0", width/2, height - 40) ; }