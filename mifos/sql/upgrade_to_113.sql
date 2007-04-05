-- drop confusing old tables that weren't being used
DROP TABLE IF EXISTS CUSTOMER_SURVEY;
DROP TABLE IF EXISTS PRD_SURVEY;
DROP TABLE IF EXISTS ACCOUNT_SURVEY;
DROP TABLE IF EXISTS SURVEY;
DROP TABLE IF EXISTS SURVEY_TEMPLATE;

-- start tables for surveys module
CREATE TABLE SURVEY (
  SURVEY_ID INTEGER AUTO_INCREMENT NOT NULL,
  SURVEY_NAME VARCHAR(200) NOT NULL,
  SURVEY_APPLIES_TO VARCHAR(200) NOT NULL,
  DATE_OF_CREATION INTEGER NOT NULL,
  STATE INTEGER NOT NULL,
  PRIMARY KEY(SURVEY_ID)
);

CREATE TABLE SURVEY_INSTANCE (
  INSTANCE_ID INTEGER AUTO_INCREMENT NOT NULL,
  SURVEY_ID INTEGER NOT NULL,
  CLIENT_ID INTEGER NOT NULL,
  OFFICER_ID SMALLINT NOT NULL,
  DATE_CONDUCTED DATE NOT NULL,
  COMPLETED_STATUS INTEGER NOT NULL,
  PRIMARY KEY(INSTANCE_ID),
  FOREIGN KEY(SURVEY_ID)
    REFERENCES SURVEY(SURVEY_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(CLIENT_ID) 
    REFERENCES CUSTOMER(CUSTOMER_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(OFFICER_ID)
    REFERENCES PERSONNEL(PERSONNEL_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
);

CREATE TABLE QUESTIONS (
  QUESTION_ID INTEGER NOT NULL,
  ANSWER_TYPE INTEGER NOT NULL,
  QUESTION_STATE INTEGER NOT NULL,
  QUESTION_TEXT VARCHAR(1000) NOT NULL,
  NUMERIC_MIN INTEGER,
  NUMERIC_MAX INTEGER,
  PRIMARY KEY(QUESTION_ID)
);

CREATE TABLE SURVEY_QUESTIONS (
  SURVEY_ID INTEGER NOT NULL,
  QUESTION_ID INTEGER NOT NULL,
  QUESTION_ORDER INTEGER NOT NULL,
  MANDATORY SMALLINT  DEFAULT 1  NOT NULL,
  FOREIGN KEY(QUESTION_ID)
    REFERENCES QUESTIONS(QUESTION_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(SURVEY_ID)
    REFERENCES SURVEY(SURVEY_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
);

CREATE TABLE SURVEY_RESPONSE_CHOICE (
  RESPONSE_ID INTEGER AUTO_INCREMENT NOT NULL,
  INSTANCE_ID INTEGER NOT NULL,
  QUESTION_ID INTEGER NOT NULL,
  CHOICE_ID INTEGER NOT NULL,
  PRIMARY KEY(RESPONSE_ID),
  FOREIGN KEY(QUESTION_ID)
    REFERENCES QUESTIONS(QUESTION_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(INSTANCE_ID)
    REFERENCES SURVEY_INSTANCE(INSTANCE_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
);


CREATE TABLE QUESTION_CHOICES (
  CHOICE_ID INTEGER AUTO_INCREMENT NOT NULL,
  QUESTION_ID INTEGER NOT NULL,
  CHOICE_TEXT VARCHAR(200) NOT NULL,
  CHOICE_ORDER INTEGER NOT NULL,
  PRIMARY KEY(CHOICE_ID),
  FOREIGN KEY(QUESTION_ID)
    REFERENCES QUESTIONS(QUESTION_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
);

CREATE TABLE SURVEY_RESPONSE_FREETEXT (
  RESPONSE_ID INTEGER AUTO_INCREMENT NOT NULL,
  INSTANCE_ID INTEGER NOT NULL,
  QUESTION_ID INTEGER NOT NULL,
  FREETEXT_ANSWER TEXT,
  PRIMARY KEY(RESPONSE_ID),
  FOREIGN KEY(QUESTION_ID)
    REFERENCES QUESTIONS(QUESTION_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(INSTANCE_ID)
    REFERENCES SURVEY_INSTANCE(INSTANCE_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
);

CREATE TABLE SURVEY_RESPONSE_NUMBER (
  RESPONSE_ID INTEGER AUTO_INCREMENT NOT NULL,
  INSTANCE_ID INTEGER NOT NULL,
  QUESTION_ID INTEGER NOT NULL,
  NUMBER_ANSWER DECIMAL(16,5),
  PRIMARY KEY(RESPONSE_ID),
  FOREIGN KEY(QUESTION_ID)
    REFERENCES QUESTIONS(QUESTION_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(INSTANCE_ID)
    REFERENCES SURVEY_INSTANCE(INSTANCE_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
);

CREATE TABLE SURVEY_RESPONSE_DATE (
  RESPONSE_ID INTEGER AUTO_INCREMENT NOT NULL,
  INSTANCE_ID INTEGER NOT NULL,
  QUESTION_ID INTEGER NOT NULL,
  DATE_ANSWER DATE,
  PRIMARY KEY(RESPONSE_ID),
  FOREIGN KEY(QUESTION_ID)
    REFERENCES QUESTIONS(QUESTION_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(INSTANCE_ID)
    REFERENCES SURVEY_INSTANCE(INSTANCE_ID)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
);

-- end tables for surveys module


UPDATE DATABASE_VERSION SET DATABASE_VERSION = 113 WHERE DATABASE_VERSION = 112;
