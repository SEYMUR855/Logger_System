------------------------------
-- MUST BE EXECUTED ON MAIN SCHEME
-- CREATES HISTORY TRIGGERS
------------------------------

DECLARE
	HISTORY_SCHEME_NAME VARCHAR2(50) DEFAULT 'AGAPUS_HISTORY';

  l_char_loc NUMBER(10,0);
  l_trg_name VARCHAR2(100);
  l_sql_stmt VARCHAR2(10000);
BEGIN  
  FOR tbls IN 
    (SELECT * 
      FROM user_tables 
      WHERE --table_name LIKE 'AG_%' AND
			 table_name IN
        (
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
	'AG_PEN_INVALIDATIONS'
	'AG_PEN_PART_TYPE_DET',
	'AG_PEN_PARTS',
	'AG_PEN_REAL_WORK_EXPERIENCES',
	'AG_PEN_SIGN_INFO',
	'AG_PEN_SP_ST',
	'AG_PEN_WORK_EXPERIENCES',
	'AG_PENSIONER_PHOTOS',
	'AG_PENSIONER_RECOGNITION',
	'AG_PENSIONERS',
	'AG_PERSONS',
	'AG_SIGNED_DOCUMENTS',
	'AG_SPECIAL_STATUSES',
	'AG_USER_FIELDS'
        )
	)
  LOOP

    -- Construct trigger name
    l_trg_name := 'TRG_H_';
		l_trg_name := l_trg_name || SUBSTR(tbls.table_name, 4);
		l_trg_name := substr(l_trg_name,1, 30);
		
    l_sql_stmt := chr(10) || 'CREATE OR REPLACE TRIGGER ' || l_trg_name
                  || chr(10) || 'BEFORE INSERT OR DELETE OR UPDATE OF' || chr(10);
                  
    FOR cols IN (SELECT *
                  FROM user_tab_cols
                  WHERE table_name  = tbls.table_name
                  AND column_name NOT IN ('ARCHIVED_USER', 'REGUSER', 'REGDATE', 'EDITUSER', 'EDITDATE' )
                  AND data_type != 'BLOB'
                  AND virtual_column = 'NO'
                  ORDER BY COLUMN_ID)
    LOOP      
        l_sql_stmt := l_sql_stmt || ' ' || cols.column_name || ',' || chr(10);
    END LOOP;
    
    l_sql_stmt := TRIM(TRAILING ',' FROM TRIM(TRAILING chr(10) FROM l_sql_stmt)) 
                  || chr(10) || 'ON ' || tbls.table_name
                  || chr(10) || 'FOR EACH ROW'
                  || chr(10) || 'DECLARE'
                  || chr(10) || '   history_row '||HISTORY_SCHEME_NAME||'.' || tbls.table_name || '%rowtype;'
                  || chr(10) || 'BEGIN';
				

	l_sql_stmt := l_sql_stmt || chr(10) || ' IF INSERTING THEN' || chr(10) ||
					'   -- If inserting set EDITUSER and EDITDATE to null' || chr(10) ||
					'   :NEW.EDITUSER := NULL;' || chr(10) ||
					'   :NEW.EDITDATE := NULL;';
					
	l_sql_stmt := l_sql_stmt || chr(10) || ' ELSE'|| CHR(10);
	l_sql_stmt := l_sql_stmt || '  IF UPDATING THEN' || chr(10);
	
	-- Check for EDITUSER and EDITDATE
	l_sql_stmt := l_sql_stmt ||
				'   IF(NOT UPDATING(''EDITUSER'') ' ||
				'		OR :NEW.EDITUSER IS NULL) THEN ' || chr(10) ||
				'      RAISE_APPLICATION_ERROR(-20001, ''EDITUSER MUST BE PROVIDED'');' || chr(10) ||
				'   END IF;';
  
    l_sql_stmt := l_sql_stmt || chr(10) || chr(10) || '   IF (1 = 0' || chr(10);
  
    -- Get columns and compare them to determine if data should be inserted into log table
    FOR cols IN (SELECT *
                  FROM user_tab_cols
                  WHERE table_name     = tbls.table_name
                  AND column_name NOT IN ('REGUSER', 'REGDATE', 'EDITUSER', 'EDITDATE' )
                  AND data_type != 'BLOB'
                  AND virtual_column = 'NO'
                  ORDER BY COLUMN_ID)
    LOOP    
      
      l_sql_stmt := l_sql_stmt ||
                    '     OR UTILITIES_PACKAGE.ARE_EQUAL(:OLD.' || cols.column_name || ', :NEW.' || cols.column_name  || ') = 0' || chr(10);
    END LOOP;
    
    -- Prepare data to insert into history table
    l_sql_stmt := l_sql_stmt || '     ) THEN' || chr(10)
		|| '        -- If any data has been changed set EDITDATE' || chr(10)
		|| '        :NEW.EDITDATE := SYSDATE;' || chr(10)
    || '        -- Never update REGUSER and REGDATE' || chr(10)
    || '        :NEW.REGUSER := :OLD.REGUSER;' || chr(10)
    || '        :NEW.REGDATE := :OLD.REGDATE;' || chr(10)|| chr(10)
		|| '        history_row.ARCHIVED_REASON := 1;' || chr(10)
		|| '        history_row.ARCHIVED_USER := :NEW.EDITUSER;' || chr(10)
		|| '   ELSE' || CHR(10)
		|| '        --Not Updating' || chr(10)
		|| '        :NEW.EDITUSER := :OLD.EDITUSER;' || chr(10)
		|| '        :NEW.EDITDATE := :OLD.EDITDATE;' || chr(10)
		|| '        RETURN;' || chr(10)
		|| '   END IF;' || CHR(10) || CHR(10)
		|| '  ELSE' || CHR(10)
		|| '   --Deleting' || CHR(10)
		|| '   history_row.ARCHIVED_REASON := 2;' || CHR(10)
		|| '   history_row.ARCHIVED_USER := :OLD.ARCHIVED_USER;' || CHR(10)
		|| '  END IF;' || CHR(10);
		
		
      
      
    FOR cols IN (SELECT *
                  FROM user_tab_cols
                  WHERE table_name = tbls.table_name
                  --AND data_type != 'BLOB'
									AND column_name != 'ARCHIVED_USER'
                  AND virtual_column = 'NO'
                  ORDER BY COLUMN_ID)  
    LOOP
			IF cols.data_type = 'BLOB' THEN
				l_sql_stmt := l_sql_stmt ||'    IF DELETING THEN '|| CHR(10);
				l_sql_stmt := l_sql_stmt ||'   		history_row.' || cols.column_name || ' := :OLD.' ||  cols.column_name || ';' || chr(10);
				l_sql_stmt := l_sql_stmt ||'    END IF;'|| CHR(10);
			ELSE
				l_sql_stmt := l_sql_stmt || '    history_row.' || cols.column_name || ' := :OLD.' ||  cols.column_name || ';' || chr(10);
			END IF;
    END LOOP;
    
    l_sql_stmt := l_sql_stmt || '    history_row.ARCHIVED_DATE := SYSDATE;' || chr(10);
    
    l_sql_stmt := l_sql_stmt || chr(10)	|| '    INSERT INTO '
          ||HISTORY_SCHEME_NAME||'.' || tbls.table_name || chr(10) 
          || '    VALUES history_row;' || chr(10);

    
    
    l_sql_stmt := l_sql_stmt || chr(10) || ' END IF;';
    
    l_sql_stmt := l_sql_stmt || chr(10) || 'END;';
      
    --DBMS_OUTPUT.put_line(tbls.table_name);
    EXECUTE IMMEDIATE l_sql_stmt;
	-- DBMS_OUTPUT.put_line(l_sql_stmt);
  END LOOP;
END;