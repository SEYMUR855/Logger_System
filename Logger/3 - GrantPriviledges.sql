------------------------------
-- MUST BE EXECUTED ON HISTORY SCHEME
------------------------------

DECLARE
	SCHEME_NAME VARCHAR2(50) DEFAULT 'AGAPUS';
	
  l_sql_stmt VARCHAR2 (2000 CHAR);
BEGIN
  FOR x IN
  (
	  SELECT * 
      FROM user_tables 
      WHERE table_name IN(
		--Comma separated column names
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
    l_sql_stmt := 'GRANT SELECT ON ' || x.table_name || ' TO '||SCHEME_NAME||' ';
    -- DBMS_OUTPUT.put_line(l_sql_stmt);
    EXECUTE IMMEDIATE l_sql_stmt;
		
		l_sql_stmt := 'GRANT INSERT ON ' || x.table_name || ' TO '||SCHEME_NAME||' ';
    -- DBMS_OUTPUT.put_line(l_sql_stmt);
    EXECUTE IMMEDIATE l_sql_stmt;
		
  END LOOP;
END;