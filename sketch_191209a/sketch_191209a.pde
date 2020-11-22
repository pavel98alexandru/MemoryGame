import processing.serial.*;

/* Serial-ul disponibil pentru trimiterea/primirea de informatie de la Arduino*/

Serial port0;  

/* Variabilele necesare jocului, cu nume explicite pentru functie*/
int vietip1=3;
int vietip2=3;
int scorp1=0;
int scorp2=0;
PFont font;
String comandaPrimitaBT=null;
String culoare=null;
long counterProgr=0;
boolean flagAsteptare=false;
long timpAsteptare;
boolean flagEcranGetReady=true;
boolean flagClickStanga=false;
int level=1;
boolean flagNivel=false;
long timpAsteptarePatrate;
int nrPatrate=0;
boolean flagPlayerTurn=false;
String[] culori=new String[8];
String[] culoriReceived=new String[8];
int countReceive = 0;
int playerFlag=1;
int winner=0;
int points=0;
long waitPatrate=0;
long afisajTime=0;
boolean levelWon=false;
String prevColor="";
boolean done=false;

void setup() {
  size(1920, 1080);
  port0=new Serial(this, "COM5", 9600);
  paintGUI();
}

/* Secventa pentru desenarea interfetei grafice */
void paintGUI()
{
  PImage img=loadImage("culori.jpg");
  background(0);
  image(img,0,0);
  textSize(50);
  fill(109, 255, 229);
  text("    Click Dreapta => START                                    Culori corecte < 3 => - ❤", 0, 1040);
  playerStats();
}

/* Secventa de desenare a statisticilor playerilor: scorul si viata + indicarea NIVELULUI si randul jucatorului*/
void playerStats()
{

  fill(120, 86, 169);
  textSize(50);
  text("PLAYER 1 ", 120, 120);
  text("PLAYER 2 ", 120, 240);
  String vieti="";
  for (int i=0; i<vietip1; i++)
  {
    vieti+="   ❤";
  }
  fill(230, 20, 14);
  text(vieti, 400, 120);
  vieti="";
  for (int i=0; i<vietip2; i++)
  {
    vieti+="   ❤";
  }
  text(vieti, 400, 240);
  fill(120, 86, 169);
  text("SCORE P1: ", 1100, 120);
  text("SCORE P2: ", 1100, 240);
  fill(230, 20, 14);
  text(scorp1, 1400, 120);
  text(scorp2, 1400, 240);
  fill(138, 240, 199);
  textSize(80);
  text("LEVEL "+level+"    PLAYER "+playerFlag+" turn", 500, 440);
}

/* Citirea de pe portul Serial legat la Arduino */
void readFromSerial()
{
  if (port0.available()>0)
  {
    comandaPrimitaBT=port0.readString();
  }
}

/* Buzzer-ul care bipaie diferit pentru raspuns corect/gresit */
void buzz(boolean corect)
{
  if (corect)
  {
    port0.write("corect");
  } else
  {
    port0.write("fals");
  }
}

/* generare culoare random pentru succesiunea de retinut */
void generareCuloare()
{
  do
  {
  int nr=(int)random(1, 5);
  switch(nr)
  {
  case 1:
    culoare="rosu";
    break;
  case 2:
    culoare="verde";
    break;
  case 3:
    culoare="albastru";
    break;
  case 4:
    culoare="galben";
    break;
  }
  }while(culoare.equals(prevColor));
  prevColor=culoare;
}

/*Functie pentru generarea timpului de asteptare folosit in multiple instante */
float generareTimp(float a, float b)
{
  float timp=random(a, b);
  return timp*80;
}

/* Desenare patrate de culoare care reprezinta culoarea curenta din succesiune */
void desenarePatrate()
{
  if (flagAsteptare)
  {
    flagEcranGetReady=false;  
    float timp=generareTimp(0.5, 2);
    timpAsteptare=counterProgr+(long)(30*timp);
    generareCuloare();
    if (culoare=="rosu")
    {
      fill(253, 0, 0);
      rect(300, 300, 1300, 600);
    }
    if (culoare=="verde")
    {
      fill(3, 231, 55);
      rect(300, 300, 1300, 600);
    }
    if (culoare=="albastru")
    {
      fill(5, 67, 231);
      rect(300, 300, 1300, 600);
    }
    if (culoare=="galben")
    {
      fill(243, 255, 57);
      rect(300, 300, 1300, 600);
    }
     port0.write(culoare);
  }
}

/* Resetare totala */
void reset()
{
  vietip1=3;
  vietip2=3;
  scorp1=0;
  scorp2=0;
  comandaPrimitaBT=null;
  culoare=null;
  counterProgr=0;
  flagAsteptare=false;
  flagEcranGetReady=true;
  flagClickStanga=false;
  level=1;
  flagNivel=false;
  nrPatrate=0;
  flagPlayerTurn=false;
  culori=new String[8];
  culoriReceived=new String[8];
  countReceive = 0;
  playerFlag=1;
  winner=0;
  points=0;
  waitPatrate=0;
  afisajTime=0;
  levelWon=false;
}

/* Rularea interfetei */
void draw() {
  if(done && timpAsteptare==counterProgr)
  {
    paintGUI();
  }
  if ((mousePressed &&(mouseButton==LEFT)) || flagClickStanga)
  {
    
    /* Daca s-a apasat mouse stanga incepe jocul */
    flagClickStanga=true;
    if (flagEcranGetReady)
    {
      if (!flagAsteptare)
      {
        /*Generarea timpului de asteptare pana la succesiunea de culori*/
        float timp=generareTimp(1, 3);
        port0.write("getReady");
        flagAsteptare=true;
        timpAsteptare=counterProgr+(long)(timp);
      }
      fill(253, 14, 15);
      textSize(150);
      text("GET READY!", 500, 800);
    }
    if (timpAsteptare==counterProgr && !flagPlayerTurn)
    {
      /*Timpul de asteptare s-a scurs, succesiunea de culori va incepe*/
      if (!flagNivel)
      {
        /* Generare timp pentru durata fiecarei culori*/
        flagNivel=true;
        float timp=generareTimp(0.4, 1);
        timpAsteptarePatrate=(long)(counterProgr+timp);
      }
      if (timpAsteptarePatrate==counterProgr && nrPatrate<=level+3)
      {
        /* Se trece la urmatoarea culoare */
        println(flagPlayerTurn+" "+counterProgr+" " +flagAsteptare);
        paintGUI();
        desenarePatrate();
        culori[nrPatrate]=culoare;
        nrPatrate++;
        flagNivel=false;
      } else if (nrPatrate==level+4)
      {
        /* S-au afisat toate culorile */
        nrPatrate=0;
        flagPlayerTurn=true;
        paintGUI();
      }
      timpAsteptare=counterProgr+1; 
    }
  }

  if (flagPlayerTurn)
  {
    /* Randul player-ului la introducerea culorilor de la telecomanda/dispozitiv cu Bluetooth */
    if (waitPatrate==0)
    {
      fill(148, 32, 229);
      textSize(80);
      text("ENTER THE COLOURS", 550, 640);
    }
    if (countReceive<=level+3)
    {
      /* Se asteapta introducerea tuturor culorilor */
      if (port0.available()>0)
      {
        culoriReceived[countReceive]=port0.readString();
        countReceive++;
        waitPatrate=160+counterProgr;
      }
    }
    if (countReceive==level+3 && waitPatrate!=counterProgr)
    {
      /* S-au introdus toate culorile, acum se afiseaza raspunsul player-ului pe ecran */
      paintGUI();
      textSize(44);
      for (int i=0; i<level+3; i++)
      {
        if (culoriReceived[i].contains(culori[i]))
        {
          points++;
          if (culori[i].equals("rosu"))
          {
            fill(253, 0, 0);
            rect(i*240, 600, 240, 240);
          }
          if (culori[i].equals("verde"))
          {
            fill(47, 250, 10);
            rect(i*240, 600, 240, 240);
          }
          if (culori[i].equals("albastru"))
          {
            fill(47, 18, 254);
            rect(i*240, 600, 240, 240);
          }
          if (culori[i].equals("galben"))
          {
            fill(249, 247, 2);
            rect(i*240, 600, 240, 240);
          }
          fill(254, 254, 250);
          text("   +100P", i*240, 750);
        } else
        {
          if (culoriReceived[i].contains("rosu"))
          {
            fill(253, 0, 0);
            rect(i*240, 600, 240, 240);
          }
          if (culoriReceived[i].contains("verde"))
          {
            fill(47, 250, 10);
            rect(i*240, 600, 240, 240);
          }
          if (culoriReceived[i].contains("albastru"))
          {
            fill(47, 18, 254);
            rect(i*240, 600, 240, 240);
          }
          if (culoriReceived[i].contains("galben"))
          {
            fill(249, 247, 2);
            rect(i*240, 600, 240, 240);
          }
          fill(74, 227, 178);
          text("   WRONG!", i*240, 750);
        }
      }
      countReceive=0;
      afisajTime=360+counterProgr;
    }
    if (waitPatrate==counterProgr)
    {   
      /* Sectiunea care evalueaza raspunsul player-ului */
      if (points<3)
      {
        port0.write("fals");
        textSize(150);
        fill(255, 23, 3);
        text("-1 x ❤", 600, 570);
        if (playerFlag==1)
        {
          vietip1--;
          if (vietip1==0)
          {
            winner=2;
          }
          playerFlag=2;
        } else
        {
          vietip2--;
          if (vietip2==0)
          {
            winner=1;
          }
          playerFlag=1;
        }
        if (levelWon)
        {
          level++;
          levelWon=false;
        }
        points=0;
      } 
      else
      {
        port0.write("adevarat");
        levelWon=true;
        textSize(150);
        fill(255, 23, 3);
        text(points+" x 100 => "+points*100+" points!", 50, 570);
        if (playerFlag==1)
        {
          scorp1+=100*points;
          points=0;
          playerFlag=2;
        } else
        {
          scorp2+=100*points;
          points=0;
          playerFlag=1;
          level++;
        }
        points=0;
      }
    }

    if (afisajTime==counterProgr)
    {
      /* Resetare variabile folosite in interiorul executiei (in draw) */
      paintGUI();
      flagPlayerTurn=false;
      flagClickStanga=false;
      flagEcranGetReady=true;  
      flagAsteptare=false;
      flagNivel=false;
      waitPatrate=0;
    }
  }

  if(winner!=0)
  {
    /* Anuntare castigator */
    done=true;
    switch(winner)
    {
    case 1:
      paintGUI();
      textSize(150);
      fill(255, 23, 3);
      text(" PLAYER "+winner+" WON!", 400, 570);
      reset();
      break;
    case 2:
      paintGUI();
      textSize(150);
      fill(255, 23, 3);
      text(" PLAYER "+winner+" WON!", 400, 570);
      reset();
      break;
    }
    timpAsteptare=(long)(counterProgr+240);
  }
  counterProgr++; /* counter-ul programului, necesar datorita faptului ca Processing nu implementeaza functia delay() la fel ca Arduino, iar millis() nu este mereu precisa */
}
