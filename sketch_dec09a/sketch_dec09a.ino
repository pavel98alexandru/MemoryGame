#include <SoftwareSerial.h>

/* Serial Software pentru conexiunea prin modulul Bluetooth*/
SoftwareSerial Bluetooth(9, 8);

/* Buzzer pentru sunetele prezente in joc */ 
const int buzzer = 10;

/* Led-urile colorate */
const int rosu = 7;
const int verde = 6;
const int albastru = 5;
const int galben = 4;

/* Butoanele asociate culorilor*/
const int brosu = 3;
const int bverde = A4;
const int balbastru = 12;
const int bgalben = 13;

/* Valoare ultimului buton apasat astfel incat butoanele sa transmita culorile singular pe Serial */
String oldval = "";

void setup() {
  Serial.begin(9600);
  Serial.setTimeout(10);
  Bluetooth.begin(9600);
  Bluetooth.setTimeout(10);
  pinMode(buzzer, OUTPUT);
  noTone(buzzer);
  pinMode(rosu, OUTPUT);
  pinMode(verde, OUTPUT);
  pinMode(albastru, OUTPUT);
  pinMode(galben, OUTPUT);
  pinMode(brosu, INPUT);
  pinMode(bverde, INPUT);
  pinMode(balbastru, INPUT);
  pinMode(bgalben, INPUT);
}

void loop() {
  if (Bluetooth.available())
  {
    /* Se citeste culoarea trimisa de pe controller-ul bluetooth si se trimite pe Serial spre Processing*/
    String msg = Bluetooth.readString();
    Serial.println(msg);
  }

  /* Secventa de ferificare a butonului apasat si transmiterea acestuia spre Processing*/
  if (digitalRead(bgalben) == HIGH)
  {
    if (oldval != "galben")
    {
      Serial.println("galben");
      oldval = "galben";
    }
  }

  if (digitalRead(balbastru) == HIGH)
  {
    if (oldval != "albastru")
    {
      Serial.println("albastru");
      oldval = "albastru";
    }
  }

  if (digitalRead(bverde) == HIGH)
  {
    if (oldval != "verde")
    {
      Serial.println("verde");
      oldval = "verde";
    }
  }

  if (digitalRead(brosu) == HIGH)
  {
    if (oldval != "rosu")
    {
      Serial.println("rosu");
      oldval = "rosu";
    }
  }

  /* Secventa de primire de informatie de la Processing*/
  if (Serial.available())
  {
    String msg = Serial.readString();
    if (msg == "fals")
    {
      /* User-ul a introdus mai putin de 3 culori corecte */
      analogWrite(buzzer, 250);
      delay(100);
      analogWrite(buzzer, 50);
      delay(100);
      noTone(buzzer);
      digitalWrite(rosu, LOW);
      digitalWrite(verde, HIGH);
      digitalWrite(albastru, HIGH);
      digitalWrite(galben, HIGH);
      delay(200);
      digitalWrite(rosu, LOW);
      digitalWrite(verde, LOW);
      digitalWrite(albastru, HIGH);
      digitalWrite(galben, HIGH);
      delay(200);
      digitalWrite(rosu, LOW);
      digitalWrite(verde, LOW);
      digitalWrite(albastru, LOW);
      digitalWrite(galben, HIGH);
      delay(200);
      digitalWrite(rosu, LOW);
      digitalWrite(verde, LOW);
      digitalWrite(albastru, LOW);
      digitalWrite(galben, LOW);
      delay(200);
      digitalWrite(rosu, HIGH);
      digitalWrite(verde, HIGH);
      digitalWrite(albastru, HIGH);
      digitalWrite(galben, HIGH);
    }
    else if (msg == "adevarat")
    {
      /* User-ul a introdus o secventa de mai mult de 2 culori corecte*/
      digitalWrite(rosu, LOW);
      digitalWrite(verde, LOW);
      digitalWrite(albastru, LOW);
      digitalWrite(galben, LOW);
      delay(200);
      digitalWrite(rosu, LOW);
      digitalWrite(verde, LOW);
      digitalWrite(albastru, LOW);
      digitalWrite(galben, HIGH);
      delay(200);
      digitalWrite(rosu, LOW);
      digitalWrite(verde, LOW);
      digitalWrite(albastru, HIGH);
      digitalWrite(galben, HIGH);
      delay(200);
      digitalWrite(rosu, LOW);
      digitalWrite(verde, HIGH);
      digitalWrite(albastru, HIGH);
      digitalWrite(galben, HIGH);
      delay(200);
      digitalWrite(rosu, HIGH);
      digitalWrite(verde, HIGH);
      digitalWrite(albastru, HIGH);
      digitalWrite(galben, HIGH);
      delay(200);
      analogWrite(buzzer, 350);
      delay(200);
      analogWrite(buzzer, 650);
      delay(400);
      noTone(buzzer);
    }
    else if (msg == "getReady")
    {
      /* Alerta pentru pregatirea player-ului pentru succesiunea de culori ce va urma */
      digitalWrite(rosu, HIGH);
      digitalWrite(verde, HIGH);
      digitalWrite(albastru, HIGH);
      digitalWrite(galben, HIGH);
      analogWrite(buzzer, 100);
      delay(200);
      analogWrite(buzzer, 600);
      delay(200);
      noTone(buzzer);
      delay(200);
      analogWrite(buzzer, 100);
      delay(200);
      analogWrite(buzzer, 600);
      delay(200);
      noTone(buzzer);
    }
    else if ((msg == "rosu") || (msg == "verde") || (msg = "albastru") || (msg == "galben"))
    {
      /* Secventa pentru aprinderea led-ului de culoare potrivita pe telecomanda */
      if (msg == "rosu")
      {
        digitalWrite(rosu, HIGH);
        digitalWrite(verde, LOW);
        digitalWrite(albastru, LOW);
        digitalWrite(galben, LOW);
      }
      if (msg == "verde")
      {
        digitalWrite(rosu, LOW);
        digitalWrite(verde, HIGH);
        digitalWrite(albastru, LOW);
        digitalWrite(galben, LOW);
      }
      if (msg == "albastru")
      {
        digitalWrite(rosu, LOW);
        digitalWrite(verde, LOW);
        digitalWrite(albastru, HIGH);
        digitalWrite(galben, LOW);
      }
      if (msg == "galben")
      {
        digitalWrite(rosu, LOW);
        digitalWrite(verde, LOW);
        digitalWrite(albastru, LOW);
        digitalWrite(galben, HIGH);
      }
      analogWrite(buzzer, 600);
      delay(200);
      digitalWrite(rosu, HIGH);
      digitalWrite(verde, HIGH);
      digitalWrite(albastru, HIGH);
      digitalWrite(galben, HIGH);
      noTone(buzzer);
    }
  }
}

void noTone(int buzzer)
{
  /* Buzzer-ul este activ pe LOW, asa ca am suprascris functia noTone */
  digitalWrite(buzzer, HIGH);
}
