////////////////////////////////Libraries////////////////////////////////
import processing.net.*;
import controlP5.*;
/////////////////////////////////////////////////////////////////////////
////////////////////////////////objects//////////////////////////////////
Client c;
Table table;
Table t2;
ControlP5 cp5;
/////////////////////////////////////////////////////////////////////////
///////////////////////////////Variables/////////////////////////////////
String data = "000";
String send = "";
String s = "0000000";
boolean run = false;
/////////////////////////////////////////////////////////////////////////


////////////////////////////////Setup////////////////////////////////////
void setup() {
  size(800, 600);
  background(50);

  ///////////////////////////Initialize Objects//////////////////////////
  String[] ip = loadStrings("ip.txt");   
  c = new Client(this, ip[0], 23); 

  table = loadTable("Attendance_Sheet.csv", "header");
  t2 = loadTable("Reg.csv","header");
  cp5 = new ControlP5(this);
  PFont font = createFont("arial", 20);
  updateTable();
  ///////////////////////////////////////////////////////////////////////
  //////////////////////////////Display//////////////////////////////////
  cp5.addButton("Register")
    .setPosition(width/2-50, height-50)
    .setSize(100, 20)
    ;
  cp5.addTextfield("EnterName")
    .setPosition(width/2-100, height-150)
    .setSize(200, 40)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255, 0, 0))
    ;
  textFont(font);
  display();
  ///////////////////////////////////////////////////////////////////////////
}
/////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////Loop///////////////////////////////////
void draw() {

  if (c.available() > 0) { 
    while (data.length() < 7)
    {
      if (c.available() > 0)
        data = c.readString();
    }

    s = data.substring(0, 7);
    display();
    c.write(send);
    c.write('\n');
    c.clear();
    data = "000";
  }
  if (!c.active())
  {
    c.stop();
    println("No");
    display();
    String[] ip = loadStrings("ip.txt");
    c = new Client(this, ip[0], 23);  
  }
}

void display()
{
  background(50);
  ///////////////////////////First box//////////////////////////////
  fill(255, 0, 0);
  stroke(0, 255, 0);
  strokeWeight(1);
  rect(width/2-200, height/2-250, 400, 50);
  textSize(36);
  fill(0, 0, 0);
  if (!c.active())
  {
    text("Not Connected", width/2-110, height/2-210);
  } else 
  text("Connected", width/2-100, height/2-210);


  //////////////////////////Second Box//////////////////////////////
  fill(255, 255, 255);
  stroke(255, 0, 0);
  strokeWeight(1);
  rect(width/2-200, height/2-180, 400, 50);
  textSize(36);
  fill(0, 0, 0);
  text(s, width/2-85, height/2-140);

  ////////////////////////Third box//////////////////////////////////
  int x = idCheck(s);
  String name = "Not Registered";
  if (x > 0 )
  {
    TableRow row = t2.getRow(x-1);
    name = row.getString("Name");
    send = name;
  }
  fill(0, 255, 0);
  stroke(255, 0, 0);
  strokeWeight(1);
  rect(width/2-200, height/2-100, 400, 50);
  textSize(36);
  fill(0, 0, 0);
  text(name, width/2-190, height/2-65);

  /////////////////////////Fourth box/////////////////////////////////
  fill(0, 255, 0);
  stroke(255, 0, 0);
  strokeWeight(1);
  rect(width/2-200, height/2, 400, 50);
  textSize(36);
  fill(0, 0, 0);
  if (x > 0)
  {    
      TableRow newRow = table.addRow();
      int h = hour();
      String ampm;
      if(h > 12){ h = h-12; ampm = "pm";}
      else if(h == 0){ h = 12; ampm = "am";}
      else {ampm = "am";}
      String a = String.valueOf(h) + ":" + String.valueOf(minute()) + ampm;
      newRow.setString(getDate(), a);
      newRow.setString("Name", send);
      newRow.setString("Sr.",s);
      newRow.setInt("ID", table.lastRowIndex()+1);
      text("Marked", width/2-70, height/2+35);
      saveTable(table, "data/Attendance_Sheet.csv");
      send += 'M';
      delay(1000);
    
  } else {
    text("Null", width/2-50, height/2+35);
    send = "UNREGISTEREDD";
  }
}


//////////////////////////////////////////////Check entry in file///////////////////////////////////
int idCheck(String s)
{
  int count = 0;
  for (TableRow row : t2.rows())
  {
    if (row.getString("Sr.").equals(s)) { 
      count = row.getInt("ID"); 
      break;
    } else count = 0;
  }
  return count;
}


///////////////////////////////////////////////////Register Interrupt///////////////////////////////
public void Register(int theValue) {

  int x = idCheck(s);
  if (x == 0) {
    TableRow newRow = t2.addRow();
    newRow.setInt("ID", t2.lastRowIndex()+1);
    newRow.setString("Sr.", s);
    newRow.setString("Name", cp5.get(Textfield.class, "EnterName").getText()); 
    send = cp5.get(Textfield.class, "EnterName").getText()+"R";
    saveTable(t2, "data/Reg.csv");
    textSize(36);
    fill(255, 255, 255);
    text("Registered", width/2-95, height-160);
    delay(1000);
  }
}


//////////////////////////////////////////get system update//////////////////////////////////////
String getDate()
{
  String s = String.valueOf(day())+"/"+String.valueOf(month())+"/"+String.valueOf(year());
  return s;
}

///////////////////////////////////////Check for updates in date///////////////////////////////////
void updateTable()
{
  int r = table.getRowCount();
  int c = table.getColumnCount();
  String[] date = loadStrings("date.txt");
  if (!date[0].equals(getDate()))
  {
    table.addColumn(getDate());
    String[] list = split(getDate(), ' ');
    saveTable(table, "data/Attendance_Sheet.csv");
    saveStrings("data/date.txt", list);
  }
}
