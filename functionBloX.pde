/* THINGS TODO
- panning
- if zoomed in/out, the components can be drawn on places were it shouldnt be possible
- reformat printTexts to make it more compact.
- add texts for all name/number editing.
- changelog controlleren op mee kopieren (en de inhoud controlleren...)
- make new videos with audio
- update website with new videos and update servo motor block with latch.\
- multi file

BACKLOG
X make separate arrays for AND, NOR and MEMORIES. , unsure if actually needed, it may help with generating organized source code.
X exclude top row and first column for cosmetic purposes. It would be neat if we can stuff control buttons there.
- move node of a line by dragging it with LMB
- implement inverted outputs !Q
- instead of using arrow keys for panning, use RMB drag instead.
- make panning for links ( if possible ) 

CURRENT WORK:
- new videos for website


BEACON

PROGRAM FUNCTIONS IN ORDE

void setup()

// ROUND ROBIN TASKS
void draw()
    drawBackground() ;
    checkFunctionBlocks() ;
    checkDemoBlocks() ;
    checkLinePoints() ;
    printTexts() ;
    updateBlocks() ;
    drawBlocks() ;
    updateLinks() ;
    drawLinks() ;
    drawControlButtons() ;
    updateCursor() ;

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
        clearProgram() ;

    void rightMousePress()
        void deleteObject() ;
        void removeNode() ;
        void removeLink() ;

void mouseDragged()
    void dragItem() ;

void mouseMoved()
    dragLine() ;

void mouseReleased()

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
color backGroundColor = 100 ; 
color mainPanel  = 200 ;
// color mainPanel  = #5C4033 ; dark brown 
color fbColor    = #97db61  ;
color textColor  = 0 ;

PrintWriter     file ;
PrintWriter     output;
BufferedReader  input;
PImage          mouse;

ControlButton loadButton    ;
ControlButton saveButton    ;
ControlButton programButton ;
ControlButton clearButton ;
ControlButton quitButton ;

String text1 = "" ;
String text2 = "" ;

ArrayList <FunctionBlock> demoBlocks = new ArrayList() ;
ArrayList <FunctionBlock>     blocks = new ArrayList() ;
ArrayList <Link>              links  = new ArrayList() ;

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

final int   defaultGridSize  = 60 ;

int         gridSize = defaultGridSize ;
int         xOffset ;
int         yOffset ;

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
int     col_raw ;
int     row ;
int     row_raw ;
int     subCol ;
int     subRow ;
int     nItems ;
boolean locked ;
int     index ;
int     mode = idle ;
int     linkIndex = 0 ;
int     foundLinkIndex ;
int     currentType ;
int     pinNumber ;
int     delayTime ;
int     mapState ;
int     in1, in2, out1, out2 ;

int     linkQ ;
int     linkIn ;
int     linkRow ;
int     analogQ ;
int     analogIn ;
int     indexOfBlock ;

int     nAnalogBlocks ;
int     nDigitalBlocks ;

String  serialText = "";

boolean  hoverOverFB ;
boolean  hoverOverDemo ;
boolean  hoverOverPoint ;
boolean  blockMiddle ;
boolean  exitFlag ;
boolean  saved ;

String   inputFile ;
String   outputFile ;



void setup()
{ 
    selectInput("Open file", "inputSelected");
    //fullScreen() ;
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
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize, 10,  RISING, gridSize ) ) ;
    demoBlocks.add( new FunctionBlock((width-2*gridSize)/gridSize, 11, FALLING, gridSize ) ) ;

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

    loadButton    = new ControlButton(        10, height - 100, "LOAD" ) ;
    saveButton    = new ControlButton(       120, height - 100, "SAVE" ) ;
    programButton = new ControlButton(       230, height - 100, "PROGRAM") ;
    //clearButton   = new ControlButton(       340, height - 100, "CLEAR") ;
    quitButton    = new ControlButton( width-110, height - 100, "QUIT") ;
}

void draw()
{
    drawBackground() ;
    checkFunctionBlocks() ;
    checkDemoBlocks() ;
    checkLinePoints() ;
    printTexts() ;
    updateBlocks() ;
    drawBlocks() ;
    updateLinks() ;
    drawLinks() ;
    drawControlButtons() ;
    updateCursor() ;
    drawCursor() ;
    printVersion() ;
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

void drawControlButtons()
{
    text1 = "" ;
    textSize(30);  
    saveButton.draw() ;
    loadButton.draw() ;
    programButton.draw() ;
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

void checkDemoBlocks()
{
    if( mode == movingItem ) return ;

    for (int i = 0; i < demoBlocks.size(); i++)                                     // loop over all function blocks, sets index according and sets or clears 'hoverOverFB'
    { 
        hoverOverDemo = false ;

        FunctionBlock block = demoBlocks.get(i);
        
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
    foundLinkIndex = 0 ;
}

void updateCursor()
{
    // SK find some method to prevent drawing boxes were it should not during zooming out
    col_raw = mouseX / defaultGridSize ;

    col = mouseX / gridSize - xOffset ;
    int max_col = (width - 3*gridSize) / gridSize ;
    col = constrain( col, 0, max_col ) ;

    row_raw =    mouseY / defaultGridSize ;

    row =    mouseY / gridSize - yOffset ;
    int max_row = (height - 3*gridSize ) / gridSize ;
    row = constrain( row, 0, max_row ) ;


    if( mode != movingItem )
    {
        subCol = mouseX / (gridSize/3) % 3 ; // NOTE this suck balls when the gridSize is not divisable by 3
        subRow = mouseY / (gridSize/3) % 3 ;
    }  
   

    // textAlign(LEFT,TOP);
    // textSize(20);    
    // text("X: " + col,10,50);                                                         // row and col on screen.
    // text("Y: " + row,10,70);
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
    // text("X offset " + xOffset, 10, 310);
    // text("Y offset " + yOffset, 10, 330);
    // text("hoverOverDemo " + hoverOverDemo, 10, 350);

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
        FunctionBlock block = blocks.get(index);

        int type = block.getType() ;
        serialText = block.getText() ;
        if( serialText == null ) serialText = "" ;

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
            else if( type == SER_IN || type == SER_OUT )
            {
                text1 = "ENTER MESSAGE" ;
                text2 = serialText ;
            }
        }
        else if( mode == settingText )
        {
            text1 = "ENTER MESSAGE" ;
            text2 = serialText ;
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
        else if( loadButton.hoveringOver() )       {text1 = "LOAD PROGRAM" ;}
        else if( saveButton.hoveringOver() )       {text1 = "SAVE PROGRAM" ;}
        else if( programButton.hoveringOver() )    {text1 = "ASSEMBLE PROGRAM" ;}
       // else if( clearButton.hoveringOver() )      {text1 = "CLEAR PROGRAM" ;}
        else if( quitButton.hoveringOver() )       {text1 = "SAVE AND QUIT PROGRAM" ;}


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
    else                     currentType = row +  1 ; // hover over digital things

    pinNumber = 0 ;

    blocks.add( new FunctionBlock(( width- 3*defaultGridSize) / defaultGridSize, row, currentType, defaultGridSize )) ;    

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
        in1 = in2 = out1 = out2 = 0 ;
        serialText = "" ;

        FunctionBlock block = blocks.get( index ) ;
        int type = block.getType() ;

        if( type ==   DELAY 
        ||  type == CONSTANT) mode = settingDelayTime ;

        if( type ==   PULSE ) mode = settingPulseTime ;

        if( type ==     MAP ) mode = settingMapValues ;

        if( type ==  SER_IN
        ||  type == SER_OUT ) mode = settingText ;

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
    //println("foundLinkIndex: " + foundLinkIndex) ;
    links.remove( foundLinkIndex ) ;
    linkIndex -- ;
}

void dragItem() 
{
    FunctionBlock block = blocks.get(index);
    block.setPos(col-xOffset,row-yOffset); // these offsets work...
}

void dragLine()
{
    Link link = links.get( linkIndex ) ;
    link.updatePoint( col, row, subCol, subRow  ) ;
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
    ||  mode == settingMapValues || mode == settingText ) mode = idle ;                               // as long as a number is set, LMB nor RMB must do anything

    if(      mode == idle && hoverOverDemo )                                     addFunctionBlock() ;
    else if( mode == idle )                                                      moveItem() ;
    if (     mode == idle && subCol == 1 && subRow == 2 && hoverOverFB == true ) alterNumber() ;
    else if( mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true ) createLink() ;
    else if( mode == addingLinePoints && subCol == 0    && hoverOverFB == true ) finishLink() ;
    else if( mode == addingLinePoints )                                          addNodeToLink() ;
    else if( loadButton.hoveringOver() )                                         selectInput("Open file", "inputSelected");
    else if( saveButton.hoveringOver() )                                         selectOutput("Save file", "outputSelected");
    else if( programButton.hoveringOver() )                                      assembleProgram() ;
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
    saved = false ;
}
void mouseDragged()
{
    if( mouseButton ==  LEFT 
    &&  mode == movingItem )                dragItem() ;
    // if( mouseButton ==  CENTER )
    // {
    //     if( row != row_prev || col != col_prev)
    //     {   row_prev = row ;   col_prev = col ;


        
    // }
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
    if(( e > 0 && gridSize <  60 )
    || ( e < 0 && gridSize >  60 )) return ;
    gridSize -= 15* (int) e ;
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
    if (key == ESC) key = 0 ;           // discard escape key, prevents accidently terminating and lose things..
    
    if( mode == settingPin       || mode == settingDelayTime 
    ||  mode == settingPulseTime || mode == settingMapValues 
    ||  mode == settingText   )
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
                    case 0: in1  = makeNumber(  in1, 0, 65000 ) ;block.setIn1( in1) ; break ;
                    case 1: in2  = makeNumber(  in2, 0, 65000 ) ;block.setIn2( in2) ; break ;
                    case 2: out1 = makeNumber( out1, 0, 65000 ) ;block.setOut1(out1) ; break ;
                    case 3: out2 = makeNumber( out2, 0, 65000 ) ;block.setOut2(out2) ; break ;
                }
            }
            else
            {
                delayTime = makeNumber( delayTime, 0, 65000 ) ;
                block.setDelay( delayTime ) ; // used for delay and pulse generator
            }
        }
    }
    if( mode == settingText )
    {
        if( keyCode == BACKSPACE 
        &&  serialText.length() > 0 )
        {
            serialText = serialText.substring( 0, serialText.length()-1 ); 
        }
        else if( keyCode == ENTER )
        {
            mode = idle ;
        }
        else if( key >= 20 && key <= 128 )
        {
            serialText += key ;
        }
        FunctionBlock block = blocks.get( index ) ;
        block.setText( serialText ) ;
    }
    
    // if(keyCode ==    UP && yOffset >   0 ) yOffset -- ;
    // if(keyCode ==  DOWN && yOffset <  50 ) yOffset ++ ;
    // if(keyCode ==  LEFT && xOffset >   0 ) xOffset -- ;
    // if(keyCode == RIGHT && xOffset <  50 ) xOffset ++ ; 
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

    for (int i = 0; i < blocks.size() ; i++ ) // SK: BUG sometimes false entry of some non existing block...
    {
        FunctionBlock block = blocks.get(i) ;
        output.println( block.getXpos() + "," + block.getYpos() + "," 
                      + block.getType() + "," + block.getPin()  + "," 
                      + block.getDelay()+ "," 
                      + block.getIn1()  + "," + block.getIn2()  + "," 
                      + block.getOut1() + "," + block.getOut2() + ","
                      + block.getText() ) ;
    }

    output.println(links.size());           // the amount of links is saved
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
    linkIndex = 0 ;
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
        int    type = block.getType() ;
        int    time = block.getDelay() ;
        int     pin = block.getPin() ;
        String mess = block.getText() ;

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
            case  SER_IN: file.println("static     SerialIn d"+(index+1)+" = SerialIn( \""+ mess +"\") ;") ;index++ ; break ;  
            case SER_OUT: file.println("static    SerialOut d"+(index+1)+" = SerialOut(\""+ mess +"\") ;") ;index++ ; break ;  
            case RISING:  file.println("static       Rising d"+(index+1)+" = Rising()  ;") ;                index++ ; break ;  
            case FALLING: file.println("static      Falling d"+(index+1)+" = Falling() ;") ;                index++ ; break ;  
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

/* IDEAS FOR HARDWARE
CURRENT DETECTION BOARD WITH LOCONET INTERFACE.

GENERAL PURPUSE ARDUINO IO BOARD W. XNET INTERFACE.
RELAYS
SERVOS
INPUTS
OUTPUT INCL I2C
POTENTIOMETERS (2)
(CURRENT SENSORS)
TEACHIN CODE
I2C EEPROM
H BRIDGE FOR DCC OR DCC.


CONTROL PANEL MODULE WITH LOCONET INTERFACE AND OPTIONAL IO EXTENDERS

SET POINTS AND SIGNALS
MATCH LEDS WITH POINTS // in case of extern feedback
EXTRA LEDS FOR OCCUPANCY THINGS
TEACHIN CODE
I2C EEPROM

IO EXTENDERS -> 8X MCP23017, 8 inputs, 8 outputs (push-pull leds).


Servo slave module
RS485 extension module for servo's
RS485 extension module for coil controllers
arduino board with 485 interface 



*/

void printVersion() { text("V1.1.0", width/2, height - 2*gridSize) ; }