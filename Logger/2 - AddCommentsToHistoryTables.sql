------------------------------
-- MUST BE EXECUTED ON SYS
-- ADDS COMMENTS TO HISTORY TABLES
------------------------------

DECLARE
	HISTORY_SCHEME_NAME VARCHAR2(50) DEFAULT 'AGAPUS_HISTORY';

  l_sql_stmt VARCHAR2 (2000 CHAR);
BEGIN
  FOR x IN
  (SELECT OWNER,
    OBJECT_NAME
		FROM DBA_OBJECTS
		WHERE OBJECT_TYPE = 'TABLE'
		AND OWNER = HISTORY_SCHEME_NAME
		AND OBJECT_NAME IN (
			--Comma separated table names
	'AG_CARD_ORDERS',
    'AG_COMMANDS',
	'AG_FAILED_APPLIERS',
	'AG_GUARDIANS',
	'AG_IN_OUT',
	'AG_NOTIFICATIONS',
	'AG_PAYMENTS',
	'AG_PEN_ADDRESS',
	'AG_PEN_AMOUNTS',
	'AG_PEN_ASSIGN',
	'AG_PEN_CONTACT',
	'AG_PEN_DEATH_INFOS',
	'AG_PEN_DISABILITIES',
	'AG_PEN_EX_ST',
	'AG_PEN_FME',
	'AG_PEN_INSURER_ADDITIONS',
	'AG_PEN_PART_TYPE_DET',
	'AG_PEN_PARTS',
	'AG_PEN_REAL_WORK_EXPERIENCES',
	'AG_PEN_SIGN_INFO',
	'AG_PEN_SP_ST',
	'AG_PEN_WORK_EXPERIENCES',
	'AG_PENSIONER_PHOTOS',
	'AG_PENSIONER_RECOGNITION',
	'AG_PEN_INVALIDATIONS',
	'AG_PENSIONERS',
	'AG_PERSONS',
	'AG_SIGNED_DOCUMENTS',
	'AG_SPECIAL_STATUSES',
	'AG_USER_FIELDS'
		)
  )
  LOOP
    l_sql_stmt := 'ALTER TABLE '||HISTORY_SCHEME_NAME||'.' || x.object_name || chr(10) ||
		' MODIFY (ARCHIVED_REASON NUMBER(1, 0) DEFAULT 1 NOT NULL)' || chr(10);
		
    EXECUTE IMMEDIATE l_sql_stmt;
		
		l_sql_stmt := 'ALTER TABLE '||HISTORY_SCHEME_NAME||'.' || x.object_name || chr(10) ||
		' MODIFY (ARCHIVED_DATE DATE DEFAULT SYSDATE NOT NULL)' || chr(10);
		
    EXECUTE IMMEDIATE l_sql_stmt;
    
		l_sql_stmt := 
		'COMMENT ON COLUMN '||HISTORY_SCHEME_NAME||'.' || x.object_name || '.ARCHIVED_REASON IS ''Arxivə salınma səbəbi: 1 - UPDATE | 2 - DELETE''';
    
    -- DBMS_OUTPUT.put_line(l_sql_stmt);
    EXECUTE IMMEDIATE l_sql_stmt;
		
		l_sql_stmt := 
		'COMMENT ON COLUMN '||HISTORY_SCHEME_NAME||'.' || x.object_name || '.ARCHIVED_DATE IS ''Arxivə salınma tarixi''';
    
    -- DBMS_OUTPUT.put_line(l_sql_stmt);
    EXECUTE IMMEDIATE l_sql_stmt;
  END LOOP;
END;