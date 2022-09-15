/* THINGS TODO
V finalize part to create, move and delete all items, re-use things from NX GUI (DONER)
V create link if we are hovering about a Q output..
V change boxes to stripes, make extra stripe for not. And make 3 stripes per item
V create all GPIO items, inputs, outputs, ~~~pwm out, analog in~~~.
- for the analog stuff, make a map block
- make onscreen keypad to click on numbers so one may enter a number for an input for instance
- create special items like servo motors, blinking lights (auto toggling IO)
- create the arduino framework
V make 3 inputs for and and or gates
V beacon off the X and Y limits to exlude the right and bottom side (DONER)
V auto set modes, depending on where one clicks. I no longer want to use the kayboard. (DONER)
V remove subclasses and change the functionBlock class to contain type variable.. (DONER, seems to work)
- make variable gridsize workable
- store and load layout, add buttons.
V add a dynamic message box which tells you what LMB and RMB does at any time
V organize update cursor with functions.
V try to remove the locked variable, may unneeded <== was useless
V organize all texts
- add small sphere to mouse if there is anything to click. perhaps half green and half red to indicate which buttons can be pressed
- use keyboard to enter numbers, also make sure that the current index does not change


EXTRA
- make comperator for usage with analog input
- make separate arrays for AND, NOR and MEMORIES. , unsure if actually needed, it may help with generating organized source code.
- also add NAND or NOR gates or implement inverted outputs !Q
- let textSize change appropiate with gridSize for all function blox
- add panning for larger layouts

BACKLOG
- move node of a line by dragging it with LMB

CURRENT WORK:
Add a makenumber to enter number for inputs n outputs. Do this and the very basic should work


3 events:
mouse pressed ==> create line object and store initial X/Y coordinates. Inc point index
mouse drag    ==> update the current element with new X/Y coordinates
mouse release ==> increment the index counter
mousewheel    ==> alter grid size

*/

PrintWriter  file ;

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

boolean     hoverOverFB ;
boolean     hoverOverPoint ;

FunctionBlock or1 ;
FunctionBlock and1 ;
FunctionBlock sr1 ;
FunctionBlock delay1 ;
FunctionBlock not1 ;
FunctionBlock inp1 ;
FunctionBlock outp1 ;

void setup()
{
    
    fullScreen() ;
    //size( 900, 600 ) ;
    textSize( 20 );
    background(200) ;
    
    and1    = new FunctionBlock((width-gridSize)/gridSize, 0, AND, gridSize, 1 ) ;
    or1     = new FunctionBlock((width-gridSize)/gridSize, 1,  OR, gridSize, 1 ) ;
    sr1     = new FunctionBlock((width-gridSize)/gridSize, 2,   M, gridSize, 1 ) ;
    delay1  = new FunctionBlock((width-gridSize)/gridSize, 3, DEL, gridSize, 1 ) ;
    not1    = new FunctionBlock((width-gridSize)/gridSize, 4, NOT, gridSize, 1 ) ;
    inp1    = new FunctionBlock((width-gridSize)/gridSize, 5, INPUT, gridSize, 1 ) ;
    outp1   = new FunctionBlock((width-gridSize)/gridSize, 6, OUTPUT, gridSize, 1 ) ;
}

void leftMousePress()
{
    if( mode == settingNumber ) return ;                                        // as long as a number is set, LMB nor RMB must do anything

    if(mouseX > (width-gridSize) && mode == idle )
    {
        mode = movingItem ;

        index = blocks.size() - 1 ;
        currentType = row + 1 ;

        blocks.add( new FunctionBlock(( width- 2*gridSize) / gridSize, row, currentType, gridSize, index )) ;
    }

    else for (int i = 0; i < blocks.size(); i++)
    { 
        FunctionBlock block = blocks.get(i);

        if( col == block.getXpos() && subCol == 1
        &&  row == block.getYpos() && subRow == 1 )
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
    if(blocks.size() > 0 && index < blocks.size() && hoverOverFB == true )
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
    background(200) ;
    fill(230) ;
    rect(0,0,(width - gridSize) , (height - gridSize) ) ;

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
            index = i ;
            return ;
        }
    }
}

// determens if the cursor hovers above 
void checkLinePoints()
{
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

    textAlign(CENTER,TOP);
    textSize(50);    
    // text("X: " + col,10,50);                                                         // row and col on screen.
    // text("Y: " + row,10,70);
    // //if(hoverOverFB==true)text("ITEM TRUE",10,90);
    // text("index: "+ index,10,90);
    // text("mode " + mode,10,110);
    // text("subCol " + subCol,10,130);
    // text("subRow " + subRow,10,150);
   // if(hoverOverPoint == true ) text("line detected ",10,190);    
    //textAlign(CENTER,CENTER);

    text( text1,   width/3, 0 ) ;
    text( text2, 2*width/3, 0 ) ;
    textAlign(CENTER,CENTER);
}

void printTexts()
{
    if(mouseX > (width-gridSize)  && mode == idle ) // seems to work very well
    {
        text1 = "LMB = create new Function block" ;
        text2 = "" ;
    }
    else if(  mode == idle && subCol == 2 && subRow == 1 && hoverOverFB == true )
    {
        text1 = "LMB = create link" ;
        text2 = "" ;
    }
    else if( mode == idle && hoverOverFB )
    {
        text1 = "LMB = move item" ;
        text2 = "RMB = delete item" ;
    }
    else if( mode == idle && hoverOverPoint )
    {
        text1 = "LMB = move node" ;
        text2 = "RMB = delete link" ;
    }
    else if( mode == addingLinePoints && subCol == 0 && hoverOverFB == true )
    {
        text1 = "LMB = finish point" ;
        text2 = "" ;
    }
    else if( mode == addingLinePoints )
    {
        text1 = "LMB = add point" ;
        text2 = "RMB = remove last point" ;
    }
    else if( mode == movingItem)
    {
        text1 = "Moving function block" ;
        text2 = "" ;
    }
    else if( mode == settingNumber)
    {
        text1 = "SET PIN NUMBER" ;
        text2 = "" ;
    }
    else
    {
        text1 = "" ;
        text2 = "" ;
    }
}


void draw()
{
    drawBackground() ;
    updateCursor() ;
    checkFunctionBlocks() ;
    checkLinePoints() ;
    printTexts() ;
    drawBlocks() ;
    drawLinks() ;
   
}

// ASSEMBLE ARDUINO PROGRAM.
void keyPressed()
{
    // PRINT LINKS FOR DEBUGGING
    if( key== 'p' )
    {
        file = createWriter("arduinoProgram/arduinoProgram.ino");

        file.println("const int nBlocks = " + blocks.size() + " ;" ) ;
        file.println("") ;
        file.println("enum blockTypes") ;
        file.println("{") ;
        file.println("       AND = 0,") ;
        file.println("        OR, ") ;
        file.println("         M, ") ;
        file.println("       DEL, ") ;
        file.println("       NOT, ") ;
        file.println("     INPUT_PIN,") ;
        file.println("    OUTPUT_PIN,") ;
        file.println("} ;") ;
        file.print("const int typeArray[] = {" ) ;
        for( int i = 0 ; i < blocks.size() ; i ++ )
        {
            FunctionBlock block = blocks.get( i ) ;
            int type  = block.getType() ;
            if( i % 10 == 0 ) file.print("\r\n\t") ; // for every 10 array elements, add new line
            file.print(type + ", ");
        }
        file.println("} ;") ;
        file.println("") ;
        file.println("typedef struct blox") ;
        file.println("{") ;
        file.println("    uint8_t  IN1 : 1 ;") ;
        file.println("    uint8_t  IN2 : 1 ;") ;
        file.println("    uint8_t  IN3 : 1 ;") ;
        file.println("    uint8_t    Q : 1 ;") ;
        file.println("    uint8_t  pin : 5 ;") ;
        file.println("    uint8_t type : 3 ; // 8 combinations, may not be enough in the future") ;
        file.println("    //uint32_t        oldTime ;  // bad idea to use this amount of memory per block if only delays need it?") ;
        file.println("    //const uint32_t  interval ; // perhaps couple a function pointers or obj pointer to it?") ;
        file.println("} FunctionBlock ;") ;
        file.println("") ;
        file.println("FunctionBlock block [ nBlocks ] ;") ;
        file.println("") ;
        file.println("void setup()") ;
        file.println("{") ;
        file.println("    for( int i = 0 ; i < nBlocks ; i ++ )") ;
        file.println("    {") ;
        file.println("        block[i].type = typeArray[i] ;") ;
        file.println("") ;
        file.println("        switch( block[i].type )") ;
        file.println("        {") ;
        file.println("        case AND: ") ;
        file.println("            block[i].IN1 = block[i].IN2 = block[i].IN3 = 1 ; // force all AND gate INs to be 1 in case of unused things") ;
        file.println("            break ;") ;
        file.println("") ;
        file.println("        case INPUT_PIN:") ;
        file.println("            pinMode( block[i].pin, INPUT_PULLUP ) ;") ;
        file.println("            break ;") ;
        file.println("") ;
        file.println("        case OUTPUT_PIN:") ;
        file.println("            pinMode( block[i].pin, OUTPUT ) ;") ;
        file.println("            break ;") ;
        file.println("") ;
        file.println("        case DEL:       // idk do something clever with adding timers or something") ;
        file.println("            break ;") ;
        file.println("        }") ;
        file.println("    }") ;
        file.println("}") ;
        file.println("") ;
        file.println("void loop()") ;
        file.println("{") ;
        file.println("/***************** UPDATE FUNCTION BLOCKS *****************/") ;
        file.println("    for( int i = 0 ; i < nBlocks ; i ++ )") ;
        file.println("    {") ;
        file.println("        switch( block[i].type )") ;
        file.println("        {") ;
        file.println("        case AND: ") ;
        file.println("            block[i].Q = block[i].IN1 & block[i].IN2 & block[i].IN3 ;") ;
        file.println("            break ;") ;
        file.println("") ;
        file.println("        case OR: ") ;
        file.println("            block[i].Q = block[i].IN1 | block[i].IN2 | block[i].IN3 ;") ;
        file.println("            break ;") ;
        file.println("") ;
        file.println("        case M: ") ;
        file.println("            if(      block[i].IN3 ) block[i].Q = 0 ; // R") ;
        file.println("            else if( block[i].IN1 ) block[i].Q = 1 ; // S") ;
        file.println("            break ; ") ;
        file.println("") ;
        file.println("        case NOT: ") ;
        file.println("            block[i].Q = !block[i].IN2 ; ") ;
        file.println("            break ;") ;
        file.println("") ;
        file.println("        case INPUT_PIN: ") ;
        file.println("            block[i].Q = digitalRead( block[i].pin ) ;") ;
        file.println("            break ;") ;
        file.println("") ;
        file.println("        case OUTPUT_PIN: ") ;
        file.println("            digitalWrite( block[i].pin, block[i].IN2 ) ;") ;
        file.println("            break ;") ;
        file.println("") ;
        file.println("        // case DEL: for( int i = 0 ; i < n_blocks  ; i ++ )") ;
        file.println("        //     {") ;
        file.println("        //         if( block[i].Q != block[i].IN )                                   // if new state changes") ;
        file.println("        //         {") ;
        file.println("        //             if( millis() - block[i].oldTime >= block[i].interval )         // keep monitor if interval has expired") ;
        file.println("        //             {") ;
        file.println("        //                 block[i].Q = block[i].IN ;                                // if so, adopt the new state") ;
        file.println("        //             }") ;
        file.println("        //         }") ;
        file.println("        //         else") ;
        file.println("        //         {") ;
        file.println("        //             block[i].oldTime = millis() ;                                      // if new state does not change, keep setting oldTime") ;
        file.println("        //         }") ;
        file.println("        //     }") ;
        file.println("        //     break ;") ;
        file.println("        }") ;
        file.println("    }") ;
        file.println("") ;
        file.println("/***************** UPDATE LINKS *****************/") ;
        // ADD CUSTOM LINKS
        for ( int i = 0 ; i < links.size() ; i ++ ) 
        {
            Link  link = links.get( i ) ;
            int      Q = link.getQ() ;
            int subrow = link.getSubrow() ;
            int     IN = link.getIn( subrow );

            file.println("    block["+IN+"].IN"+(subrow+1)+" = block["+Q+"].Q ;") ;
        }
        
        file.println("} ;") ;
        file.close() ;
    }
}