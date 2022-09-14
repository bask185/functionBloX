/* THINGS TODO
V finalize part to create, move and delete all items, re-use things from NX GUI (DONER)
- create link if we are hovering about a Q output..
- change boxes to stripes, make extra stripe for not. And make 3 stripes per item
- create all GPIO items, inputs, outputs, pwm out, analog in.
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
- organize all texts



EXTRA
- make comperator for usage with analog input
- make separate arrays for AND, NOR and MEMORIES. , unsure if actually needed, it may help with generating organized source code.
- also add NAND or NOR gates or implement inverted outputs !Q
- let textSize change appropiate with gridSize for all function blox
- add panning for larger layouts


CURRENT WORK:
- move node of a line by dragging it with LMB
- adding input and output Function Blocks,
- need to figure out a method to couple the IO links to the function blocks indices


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

int         gridSize = 60 ;

final int   AND = 1 ;
final int    OR = 2 ;
final int     M = 3 ;
final int   DEL = 4 ;
final int   NOT = 5 ;

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

boolean     hoverOverFB ;
boolean     hoverOverPoint ;

FunctionBlock or1 ;
FunctionBlock and1 ;
FunctionBlock sr1 ;
FunctionBlock delay1 ;
FunctionBlock not1 ;

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
}

void leftMousePress()
{
    if(mouseX > (width-gridSize) && mode == idle )
    {
        mode = movingItem ;

        index = blocks.size() - 1;

        blocks.add( new FunctionBlock(( width- 2*gridSize) / gridSize, row, row+1, gridSize, index ) ) ;
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

void keyPressed()
{
    // PRINT LINKS FOR DEBUGGING
    if( key== 'p' )
    {
        ArrayList <FunctionBlock>   and_gates = new ArrayList() ;
        ArrayList <FunctionBlock>    or_gates = new ArrayList() ;
        ArrayList <FunctionBlock>    sr_gates = new ArrayList() ;
        ArrayList <FunctionBlock> delay_gates = new ArrayList() ;
        ArrayList <FunctionBlock>   not_gates = new ArrayList() ;

        for( int i = 0 ; i < blocks.size() ; i ++ )
        {
            FunctionBlock block = blocks.get( i ) ;
            int type = block.getType() ;
            
            switch( type )
            {
         // case INPUT
         // case OUTPUT
            case AND :   and_gates.add( new FunctionBlock( 1, 1, AND, 1 ) ) ; break ;
            case  OR :    or_gates.add( new FunctionBlock( 1, 1,  OR, 1 ) ) ; break ;
            case   M :    sr_gates.add( new FunctionBlock( 1, 1,   M, 1 ) ) ; break ;
            case DEL : delay_gates.add( new FunctionBlock( 1, 1, DEL, 1 ) ) ; break ;
            case NOT :   not_gates.add( new FunctionBlock( 1, 1, NOT, 1 ) ) ; break ;
            }
        }

        //int n_inputs        = inputs.size() ;
        //int n_outputs       = outputs.size() ;
        int n_and_gates     = and_gates.size() ;
        int n_or_gates      = or_gates.size() ;
        int n_sr_gates      = sr_gates.size() ;
        int n_delay_gates   = delay_gates.size() ;
        int n_not_gates     = not_gates.size() ;

        file = createWriter("FB/FB.ino"); 

        //file.println( "const int n_inputs     = "  + inputs + " ;" ) ;
        //file.println( "const int n_outputs    = "   + outputs + " ;" ) ;
        file.println( "const int n_and_gates   = "  + n_and_gates + " ;" ) ;
        file.println( "const int n_or_gates    = "   + n_or_gates + " ;" ) ;
        file.println( "const int n_sr_gates    = "   + n_sr_gates + " ;" ) ;
        file.println( "const int n_delay_gates = "+ n_delay_gates + " ;" ) ;
        file.println( "const int n_not_gates   = "  + n_not_gates + " ;" ) ;
        file.println() ;
        file.println("typedef struct INPUT") ;
        file.println("{") ;
        file.println("    uint8_t PIN ;") ;
        file.println("    uint8_t Q : 1 ;") ;
        file.println("} INPUT_PIN ;") ;
        file.println("") ;
        file.println("typedef struct OUTPUT") ;
        file.println("{") ;
        file.println("    uint8_t PIN ;") ;
        file.println("    uint8_t IN : 1 ;") ;
        file.println("} OUTPUT_PIN ;") ;
        file.println("") ;
        file.println("typedef struct AND") ;
        file.println("{") ;
        file.println("    uint8_t IN1 : 1 ;") ;
        file.println("    uint8_t IN2 : 1 ;") ;
        file.println("    uint8_t IN3 : 1 ;") ;
        file.println("    uint8_t Q   : 1 ;") ;
        file.println("} AND_GATE ;") ;
        file.println("") ;
        file.println("typedef struct OR") ;
        file.println("{") ;
        file.println("    uint8_t IN1 : 1 ;") ;
        file.println("    uint8_t IN2 : 1 ;") ;
        file.println("    uint8_t IN3 : 1 ;") ;
        file.println("    uint8_t Q   : 1 ;") ;
        file.println("} OR_GATE ;") ;
        file.println("") ;
        file.println("typedef struct SR") ;
        file.println("{") ;
        file.println("    uint8_t S : 1 ;") ;
        file.println("    uint8_t R : 1 ;") ;
        file.println("    uint8_t Q : 1 ;") ;
        file.println("} SR_GATE ;") ;
        file.println("") ;
        file.println("typedef struct DELAY  // MAY NEED TO BECOME A CLASS IN ORDER TO HANDLE THE ACTUAL TIMING PART..") ;
        file.println("{") ;
        file.println("    uint8_t         IN : 1 ;") ;
        file.println("    uint8_t         Q  : 1 ;") ;
        file.println("    uint32_t        oldTime ;") ;
        file.println("    const uint32_t  interval ; // const possible?") ;
        file.println("} DELAY_GATE ;") ;
        file.println("") ;
        file.println("typedef struct NOT") ;
        file.println("{") ;
        file.println("    uint8_t IN : 1 ;") ;
        file.println("    uint8_t Q  : 1 ;") ;
        file.println("} NOT_GATE ;") ;
        file.println() ;
        file.println("   INPUT     and_gate[   n_and_gates ] ;") ;
        file.println("AND_GATE     and_gate[   n_and_gates ] ;") ;
        file.println(" OR_GATE      or_gate[    n_or_gates ] ;") ;
        file.println(" SR_GATE      sr_gate[    n_sr_gates ] ;") ;
        file.println("DELAY_GATE delay_gate[ n_delay_gates ] ;") ;
        file.println("NOT_GATE     not_gate[   n_not_gates ] ;") ;
        file.println() ;
        file.println("void setup()" ) ;
        file.println("{" ) ;
        file.println("" ) ; // INITIALIZE INPUT/OUTPUT OBJECTS WITH PINNUMBERS
        file.println("" ) ; // SET ALL PINMODES..
        file.println("}" ) ;
        file.println("" ) ;
        file.println("void loop()" ) ;
        file.println("{" ) ;
        file.println("" ) ;
        file.println("    // INPUTS" ) ;
        file.println("    for( int i = 0 ; i < n_inputs  ; i ++ ) input[i].Q = digitalRead( input[i].PIN ) ;" ) ;
        file.println("" ) ;
        file.println("    // OUTPUTS" ) ;
        file.println("    for( int i = 0 ; i < n_inputs  ; i ++ )" ) ;
        file.println("    {" ) ;
        file.println("        digitalWrite( output[i].PIN, output[i].IN ) ;" ) ;
        file.println("    }" ) ;
        file.println("" ) ;
        file.println("    // AND GATES" ) ;
        file.println("    for( int i = 0 ; i < n_and_gates  ; i ++ )" ) ;
        file.println("    {" ) ;
        file.println("        and_gate[i].Q = and_gate[i].IN1 & and_gate[i].IN2 & and_gate[i].IN3 ;" ) ;
        file.println("    }" ) ;
        file.println("" ) ;
        file.println("    // OR GATES" ) ;
        file.println("    for( int i = 0 ; i < n_or_gates  ; i ++ )" ) ;
        file.println("    {" ) ;
        file.println("        or_gate[i].Q = or_gate[i].IN1 | or_gate[i].IN2 | or_gate[i].IN3 ;" ) ;
        file.println("    }" ) ;
        file.println("" ) ;
        file.println("    // SR MEMORY GATES" ) ;
        file.println("    for( int i = 0 ; i < n_sr_gates  ; i ++ )" ) ;
        file.println("    {" ) ;
        file.println("        if(      sr_gate[i].R ) sr_gate[i].Q = 0 ;    // reset is dominant" ) ;
        file.println("        else if( sr_gate[i].S ) sr_gate[i].Q = 1 ;" ) ;
        file.println("    }" ) ;
        file.println("" ) ;
        file.println("    // DELAY" ) ;
        file.println("    for( int i = 0 ; i < n_delay_gates  ; i ++ )" ) ;
        file.println("    {" ) ;
        file.println("        if( delay_gate[i].Q != delay_gate[i].IN )                                   // if new state changes" ) ;
        file.println("        {" ) ;
        file.println("            if( millis() - delay_gate[i].oldTime >= delay_gate[i].interval )         // keep monitor if interval has expired" ) ;
        file.println("            {" ) ;
        file.println("                delay_gate[i].Q = delay_gate[i].IN ;                                // if so, adopt the new state" ) ;
        file.println("            }" ) ;
        file.println("        }" ) ;
        file.println("        else" ) ;
        file.println("        {" ) ;
        file.println("            delay_gate[i].oldTime = millis() ;                                      // if new state does not change, keep setting oldTime" ) ;
        file.println("        }" ) ;
        file.println("    }" ) ;
        file.println("" ) ;
        file.println("    // NOT" ) ;
        file.println("    for( int i = 0 ; i < n_not_gates  ; i ++ )" ) ;
        file.println("    {" ) ;
        file.println("        not_gate[i].Q = !not_gate[i].IN ;" ) ;
        file.println("    }" ) ;
        file.println("    // add links" ) ;
        file.println("" ) ;
        file.println("} ;" ) ;

        file.close() ;
    }
}

void mousePressed() // <== MOUSE CLICK EVENT
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
    if( mode == movingItem ) { mode = idle ; }
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

    textAlign(LEFT,CENTER);
    textSize(20);    
    text("X: " + col,10,50);                                                         // row and col on screen.
    text("Y: " + row,10,70);
    //if(hoverOverFB==true)text("ITEM TRUE",10,90);
    text("index: "+ index,10,90);
    text("mode " + mode,10,110);
    text("subCol " + subCol,10,130);
    text("subRow " + subRow,10,150);
   // if(hoverOverPoint == true ) text("line detected ",10,190);    
    //textAlign(CENTER,CENTER);

    text( text1, 10, 210 ) ;
    text( text2, 10, 230 ) ;
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
