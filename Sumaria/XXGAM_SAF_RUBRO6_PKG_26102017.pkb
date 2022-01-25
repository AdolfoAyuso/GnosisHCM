CREATE OR REPLACE PACKAGE BODY APPS.XXGAM_SAF_RUBRO6_PKG
AS

   FUNCTION replace_char_esp (p_cadena IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_cadena   VARCHAR2 (4000);
   BEGIN
      v_cadena := REPLACE (p_cadena, '&', '&' || 'amp;');
      v_cadena := REPLACE (v_cadena, CHR (50081), '&#225;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50081), '&aacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50089), '&#233;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50089), '&eacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50093), '&#237;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50093), '&iacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50099), '&#243;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50099), '&oacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50106), '&#250;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50106), '&uacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50049), '&#193;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50049), '&Aacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50057), '&#201;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50057), '&Eacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50061), '&#205;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50061), '&Iacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50067), '&#211;');
      /* v_cadena := REPLACE(v_cadena, CHR(50067), '&Oacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50074), '&#218;');
      /*  v_cadena := REPLACE(v_cadena, CHR(50074), '&Uacute;'); */
      v_cadena := REPLACE (v_cadena, CHR (50065), '&#209;');
      /* v_cadena := REPLACE(v_cadena, CHR(50065), '&Ntilde;'); */
      v_cadena := REPLACE (v_cadena, CHR (50065), '&#241;');
      /* v_cadena := REPLACE(v_cadena, CHR(50097), '&ntilde'); */
      v_cadena := REPLACE (v_cadena, CHR (49844), '');
      v_cadena := REPLACE (v_cadena, CHR (50090), '');
      v_cadena := REPLACE (v_cadena, CHR (50056), 'E');
      RETURN v_cadena;
   END replace_char_esp;

   PROCEDURE P_OUTPUT (pls_msg IN VARCHAR2)
   IS
   BEGIN
      /** WRITE TO THE CONCURRENT REQUEST OUTPUT **/
      fnd_file.put_line (fnd_file.output, pls_msg);
      --DBMS_OUTPUT.put_line (pls_msg);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN;
   END P_OUTPUT;

   PROCEDURE P_LOG (pls_msg IN VARCHAR2)
   IS
   BEGIN
      /** WRITE TO THE CONCURRENT REQUEST LOG **/
      fnd_file.put_line (fnd_file.LOG, pls_msg);
      --DBMS_OUTPUT.put_line (pls_msg);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN;
   END P_LOG;
   
   
   PROCEDURE main (pso_errmsg OUT VARCHAR2
                  ,pso_errcod OUT VARCHAR2
                  ,psi_periodo in varchar2)
   IS 
/**** -Primer cursor muestra INVERSIÓN, DPRN Y MF de XXGAM_SAF_SETUP- ****/   
   cursor get_agrupado_info
   is 
        select   DISTINCT AGRUPADO grupo 
          FROM   XXGAM_SAF_SETUP
         WHERE   ID_RUBRO = '6';
   agrupado_info_rec    get_agrupado_info%ROWTYPE;   
   
/**** -Segundo cursor muestra la primera parte de la sumaria- *****/
/*** este sursosr toma como parametro el ls_agrupado del primer cursor  */
      CURSOR get_descr_info(ls_agrupado varchar2)
      IS
        SELECT   rubro rubro
                ,id_rubro num_rubro
                ,cuenta p_cuenta
                ,subcuenta p_subcuenta
                ,cuenta||'-'||subcuenta cuenta
                ,descripcion_cuenta||'-'||descripcion_subcuenta concepto
        FROM   XXGAM_SAF_SETUP
       WHERE   1 = 1
               and id_rubro = '6'
               and agrupado = ls_agrupado;
               
   descr_info_rec   get_descr_info%ROWTYPE;
   
/**** Tercer cursor que muestra la información de los acumulados  YTD PTD*****/
/** Este cursosr toma como parametro la cuenta, subcuenta y el periodo **/
   cursor get_saldo_info (ls_cuenta varchar2, ls_subcuenta varchar2, periodo varchar2)
   is
        SELECT LG.NAME LEDGER,
            SEGMENT1 || '-' || 
            SEGMENT2 || '-' || 
            SEGMENT3 || '-' || 
            SEGMENT4 || '-' || 
            SEGMENT5 || '-' || 
            SEGMENT6 || '-' || 
            SEGMENT7 || '-' || 
            SEGMENT8 ACCOUNT,
            LT.PERIOD_NAME PERIOD,
            LG.CURRENCY_CODE CURRENCY,
            DECODE (
                'A',
                'E', DECODE (
                        BA.currency_code,
                        LG.currency_code, DECODE (
                                              BA.actual_flag,
                                              'A', (NVL (
                                                       BA.period_net_dr_beq,
                                                       0)
                                                    - NVL (
                                                         BA.period_net_cr_beq,
                                                         0)),
                                              (NVL (BA.period_net_dr, 0)
                                               - NVL (BA.period_net_cr, 0))),
                        (NVL (BA.period_net_dr, 0)
                         - NVL (BA.period_net_cr, 0))),
                (NVL (BA.period_net_dr, 0) - NVL (BA.period_net_cr, 0))) PTD,
            DECODE (
                 BA.currency_code,
                 LG.currency_code, NULL,
                 'STAT', NULL,
                 DECODE (
                    LR.relationship_type_code,
                    'BALANCE', NULL,
                    DECODE (
                       BA.translated_flag,
                       'R', DECODE (
                               BA.actual_flag,
                               'A', (NVL (BA.period_net_dr_beq, 0)
                                     - NVL (BA.period_net_cr_beq, 0)),
                               NULL),
                       NULL))) PTD_CONVERTED,
            DECODE (
                'A',
                'E', DECODE (
                        BA.currency_code,
                        LG.currency_code, DECODE (
                                              BA.actual_flag,
                                              'A', ( (NVL (
                                                         BA.
                                                          begin_balance_dr_beq,
                                                         0)
                                                      - NVL (
                                                           BA.
                                                            begin_balance_cr_beq,
                                                           0))
                                                    + (NVL (
                                                          BA.
                                                           period_net_dr_beq,
                                                          0)
                                                       - NVL (
                                                            BA.
                                                             period_net_cr_beq,
                                                            0))),
                                              ( (NVL (BA.begin_balance_dr, 0)
                                                 - NVL (BA.begin_balance_cr,
                                                        0))
                                               + (NVL (BA.period_net_dr, 0)
                                                  - NVL (BA.period_net_cr, 0)))),
                        ( (NVL (BA.begin_balance_dr, 0)
                           - NVL (BA.begin_balance_cr, 0))
                         + (NVL (BA.period_net_dr, 0)
                            - NVL (BA.period_net_cr, 0)))),
                ( (NVL (BA.begin_balance_dr, 0)
                   - NVL (BA.begin_balance_cr, 0))
                 + (NVL (BA.period_net_dr, 0) - NVL (BA.period_net_cr, 0)))) YTD,
          DECODE (
                 BA.currency_code,
                 LG.currency_code, NULL,
                 'STAT', NULL,
                 DECODE (
                    LR.relationship_type_code,
                    'BALANCE', NULL,
                    DECODE (
                       BA.translated_flag,
                       'R', DECODE (
                               BA.actual_flag,
                               'A', ( (NVL (BA.begin_balance_dr_beq, 0)
                                       - NVL (BA.begin_balance_cr_beq, 0))
                                     + (NVL (BA.period_net_dr_beq, 0)
                                        - NVL (BA.period_net_cr_beq, 0))),
                               NULL),
                       NULL))) YTD_CONVERTED,
                       CC.code_combination_id code_cuenta  
FROM GL_LEDGERS LG, 
          GL_CODE_COMBINATIONS CC,
          GL_PERIODS LT,
          --Empiezan tablas extras
          GL_BALANCES BA,
          GL_LEDGER_RELATIONSHIPS LR
          --Terminan tablas extras
WHERE 1=1
            AND LG.CHART_OF_ACCOUNTS_ID = CC.CHART_OF_ACCOUNTS_ID
            AND LG.NAME='GAM_MXN'
            AND LG.PERIOD_SET_NAME=LT.PERIOD_SET_NAME
            --Empiezan filtros extras
            AND BA.CODE_COMBINATION_ID=CC.CODE_COMBINATION_ID
            AND BA.PERIOD_NAME=LT.PERIOD_NAME
            AND BA.CURRENCY_CODE=LG.CURRENCY_CODE
            AND BA.LEDGER_ID=LG.LEDGER_ID
            AND LR.SOURCE_LEDGER_ID=LR.TARGET_LEDGER_ID
            AND LG.LEDGER_ID=LR.TARGET_LEDGER_ID
            AND LR.TARGET_CURRENCY_CODE=LG.CURRENCY_CODE
            --Terminan filtros extras
            --AND ROWNUM<10000
            AND SEGMENT1='02'
            AND SEGMENT2='00'
            AND SEGMENT3='000000'
            AND SEGMENT4='0000'
            AND SEGMENT5 = ls_cuenta
            AND SEGMENT6 = ls_subcuenta
            AND SEGMENT7='0000'
            AND SEGMENT8='00'
            AND LT.PERIOD_NAME = periodo
            AND BA.ACTUAL_FLAG='A'
            --AND LG.LEDGER_ID='2021'
ORDER BY SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5, SEGMENT6, SEGMENT7, SEGMENT8;
     
    saldo_info_rec    get_saldo_info%ROWTYPE;
   
   ---Declaracion de variables------
   ls_agrupado varchar2(32767); --INVERSIÓN, MF, DPRN
   ls_cuenta varchar2(32767); --cuenta
   ls_subcuenta varchar2(32767); -- subcuenta
   ln_subtotal_inicial number; --calcula el subtotal de inv, dpn y mf al inicio del periodo
   ln_total_inicial number; --guarda el valor total despues de sumar subtotal inv, dpn y mf al inicio del periodo
   ln_subtotal_final number; --calcula el subtotal de inv, dpn y mf al final del periodo
   ln_total_final number; --guarda el valor total despues de sumar subtotal inv, dpn y mf al final del periodo
   
   --ls_periodo varchar2(32767);
   ls_periodo_anterior varchar2(32767);
   ln_subtotal_ptd number;  ----varable para sumar los ptd de INVERSIÓN, MF y DPRN
   ln_total_ptd number; --acumulado total de la sumas de los ln_subtotal_ptd
   ln_debito number; ---variable para imprimir las adiciones
   ln_credito number;   ---variable para imprimir las disminuciones
   ln_depre number;     ----resta de ln_debito - ln_credito
   /*** Variables para el package maestro ******/
   ln_inicial_ytd number;  ---variable que se usara en variable rec
   ln_final_ytd number;  ---variable que se usara en variable rec
   ln_suma_ptd number;  ---variable que se usara en variable rec
   
   lt_inversion_info_rec        XXGAM_SAF_OP_MEN_PKG.t_inversion_rec;                ---variable record para inversion
   lt_moneda_funcional_info_rec        XXGAM_SAF_OP_MEN_PKG.t_moneda_funcional_rec;  ---variable record para moneda funcional    
   lt_depreciacion_info_rec        XXGAM_SAF_OP_MEN_PKG.t_depreciacion_rec;          ---variable record para depreciacion
   
   lt_subtotal_inversion_info_rec        XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de inversion
   lt_subtotal_mf_info_rec               XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de MF
   lt_subtotal_dpn_info_rec               XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de depreciación
   
   lt_subtotal_vnl_info_rec        XXGAM_SAF_OP_MEN_PKG.t_subtotal_vnl_rec;          ---variable record para total vnl
                                      
   lt_inversion_tbl                XXGAM_SAF_OP_MEN_PKG.t_inversion_tbl;            ---variables tipo tabla para inversión
   lt_moneda_funcional_tbl         XXGAM_SAF_OP_MEN_PKG.t_moneda_funcional_tbl;     ---variables tipo tabla para MF
   lt_depreciacion_tbl             XXGAM_SAF_OP_MEN_PKG.t_depreciacion_tbl;         ---variables tipo tabla para depreciación
   
   ltt_inversion_set_rec            XXGAM_SAF_OP_MEN_PKG.t_inversion_set_rec;        ---variable tipo set inversion para inversión
   ltt_moneda_funcional_set_rec     XXGAM_SAF_OP_MEN_PKG.t_moneda_funcional_set_rec; ---variable tipo set moneda para MF
   ltt_depreciacion_set_rec         XXGAM_SAF_OP_MEN_PKG.t_depreciacion_set_rec;     ---variable tipo set depreciacion para depreciación     
   
   ltt_by_rubro_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;     ---variable tipo rubro
              
   BEGIN
   P_LOG('Inicio de programa');
   /** Codigo para recuperar el periodo anterior al del value set ***/
   select   period_name 
    into   ls_periodo_anterior
    from   gl_periods
   where   1 = 1
           and period_set_name = 'GAM'
           and   period_name not like 'AJU%'
           and END_DATE = (select   start_date 
                             from   gl_periods
                            where   1 = 1  
                                    and   period_set_name = 'GAM'
                                    and   period_name = psi_periodo) - 1; 
   P_OUTPUT('<XXGAM_SAF_RUBRO6_PKG>');
   ln_total_inicial := 0;
   ln_total_final := 0;
   ln_total_ptd := 0; 
   
      open get_agrupado_info();
      loop
            fetch get_agrupado_info into agrupado_info_rec;
            exit when get_agrupado_info%notfound;
            ls_agrupado := agrupado_info_rec.grupo;
            P_LOG('ls_agrupado:'||ls_agrupado);
            
            ln_subtotal_inicial := 0;
            ln_subtotal_final := 0;
            ln_subtotal_ptd := 0;
            P_OUTPUT('<BLOQUE>');
            OPEN get_descr_info(ls_agrupado);
            LOOP
                    FETCH get_descr_info INTO descr_info_rec;
                    EXIT WHEN get_descr_info%NOTFOUND;
                          P_OUTPUT('<GRUPO>');  
                          P_OUTPUT('<RUBRO>'||XXGAM_SAF_RUBRO6_PKG.replace_char_esp(descr_info_rec.rubro)||'</RUBRO>');
                          P_OUTPUT('<NUM_RUBRO>'||XXGAM_SAF_RUBRO6_PKG.replace_char_esp(descr_info_rec.num_rubro)||'</NUM_RUBRO>');
                          P_OUTPUT('<CUENTA>'||XXGAM_SAF_RUBRO6_PKG.replace_char_esp(descr_info_rec.cuenta)||'</CUENTA>');
                          P_OUTPUT('<CONCEPTO>'||XXGAM_SAF_RUBRO6_PKG.replace_char_esp(descr_info_rec.concepto)||'</CONCEPTO>');
                          P_LOG('rubro:'||descr_info_rec.rubro);
                          ls_cuenta := descr_info_rec.p_cuenta;
                          ls_subcuenta := descr_info_rec.p_subcuenta;
                         /* if ls_agrupado = 'INVERSION' then
                                lt_inversion_info_rec.rubro := descr_info_rec.rubro;
                                lt_inversion_info_rec.num_rubro := descr_info_rec.num_rubro;
                                lt_inversion_info_rec.cuenta := descr_info_rec.p_cuenta;
                                lt_inversion_info_rec.subcuenta := descr_info_rec.p_subcuenta;
                                lt_inversion_info_rec.concepto := descr_info_rec.concepto;
                          end if;      */
                          /*** Obtiene el acumulado del periodo anterior al que ingreso el usuario ***/
                          P_LOG('ls_periodo_anterior:'||ls_periodo_anterior);
                          P_LOG('ls_cuenta:'||ls_cuenta);
                          P_LOG('ls_subcuenta:'||ls_subcuenta);
                                OPEN get_saldo_info(ls_cuenta, ls_subcuenta, ls_periodo_anterior);
                                loop
                                        fetch get_saldo_info into saldo_info_rec;
                                        P_OUTPUT('<SALDO_INICIAL>'||saldo_info_rec.YTD||'</SALDO_INICIAL>');
                                        ln_inicial_ytd := saldo_info_rec.YTD;
                                        ln_subtotal_inicial := ln_subtotal_inicial + saldo_info_rec.YTD;
                                        P_LOG('ln subtotal inicial:'||ln_subtotal_inicial);
                                        exit;
                                end loop;
                                close get_saldo_info;      
                                /** obtiene el acumulado al periodo que ingreso el usuario **/
                                P_LOG('psi_periodo:'||psi_periodo);
                                OPEN get_saldo_info(ls_cuenta, ls_subcuenta, psi_periodo);
                                loop
                                        fetch get_saldo_info into saldo_info_rec;
                                        P_OUTPUT('<SALDO_FINAL>'||saldo_info_rec.YTD||'</SALDO_FINAL>');
                                        ln_final_ytd := saldo_info_rec.YTD;
                                        ln_subtotal_final := ln_subtotal_final + saldo_info_rec.YTD;
                                        P_OUTPUT('<SUMA>'||saldo_info_rec.PTD||'</SUMA>');
                                        ln_suma_ptd := saldo_info_rec.PTD;
                                        ln_subtotal_ptd := ln_subtotal_ptd + saldo_info_rec.PTD;
                                        ln_debito := XXGAM_SAF_UTIL_V1_PKG.ADDITION(saldo_info_rec.code_cuenta,psi_periodo,'GAM_MXN');
                                        ln_credito := XXGAM_SAF_UTIL_V1_PKG.REDUCTION(saldo_info_rec.code_cuenta,psi_periodo,'GAM_MXN');
                                        exit;
                                end loop;
                                
                                /**  informacion inversion_rec **/
                                if ls_agrupado = 'INVERSION' then
                                    lt_inversion_info_rec.rubro := descr_info_rec.rubro;
                                    lt_inversion_info_rec.num_rubro := descr_info_rec.num_rubro;
                                    lt_inversion_info_rec.cuenta := descr_info_rec.p_cuenta;
                                    lt_inversion_info_rec.subcuenta := descr_info_rec.p_subcuenta;
                                    lt_inversion_info_rec.concepto := descr_info_rec.concepto;
                                    lt_inversion_info_rec.saldo_inicial := ln_inicial_ytd;
                                    lt_inversion_info_rec.ad_altas := ln_debito;
                                    lt_inversion_info_rec.ad_dism_inversa := ln_credito;
                                   /** lt_inversion_info_rec.suma := ln_suma_ptd; **/
                                    lt_inversion_info_rec.saldo_final := ln_final_ytd; 
                                    
                                    lt_inversion_tbl(get_descr_info%ROWCOUNT) := lt_inversion_info_rec;
                                    
                                    
                                end if;      
                                
                                /** informacion ms_rec **/
                                if ls_agrupado = 'MF' then
                                    lt_moneda_funcional_info_rec.rubro := descr_info_rec.rubro;
                                    lt_moneda_funcional_info_rec.num_rubro := descr_info_rec.num_rubro;
                                    lt_moneda_funcional_info_rec.cuenta := descr_info_rec.p_cuenta;
                                    lt_moneda_funcional_info_rec.subcuenta := descr_info_rec.p_subcuenta;
                                    lt_moneda_funcional_info_rec.concepto := descr_info_rec.concepto;
                                    lt_moneda_funcional_info_rec.saldo_inicial := ln_inicial_ytd;
                                    lt_moneda_funcional_info_rec.ad_altas := ln_debito;
                                    lt_moneda_funcional_info_rec.ad_dism_inversa := ln_credito;
                                    lt_moneda_funcional_info_rec.suma := ln_suma_ptd;
                                    lt_moneda_funcional_info_rec.saldo_final := ln_final_ytd;
                                    
                                    lt_moneda_funcional_tbl(get_descr_info%ROWCOUNT) := lt_moneda_funcional_info_rec;
                                    
                                end if;      
                                
                                
                                if ls_agrupado = 'DPN' then
                                    lt_depreciacion_info_rec.rubro := descr_info_rec.rubro;
                                    lt_depreciacion_info_rec.num_rubro := descr_info_rec.num_rubro;
                                    lt_depreciacion_info_rec.cuenta := descr_info_rec.p_cuenta;
                                    lt_depreciacion_info_rec.subcuenta := descr_info_rec.p_subcuenta;
                                    lt_depreciacion_info_rec.concepto := descr_info_rec.concepto;
                                    lt_depreciacion_info_rec.saldo_inicial := ln_inicial_ytd;
                                    ln_depre := ln_debito - ln_credito;
                                    P_OUTPUT('<DEPRE>'||ln_depre||'</DEPRE>');
                                    lt_depreciacion_info_rec.depn_del_ejercicio := ln_depre;
                                    lt_depreciacion_info_rec.suma := ln_suma_ptd;
                                    lt_depreciacion_info_rec.saldo_final := ln_final_ytd;
                                    
                                    lt_depreciacion_tbl(get_descr_info%ROWCOUNT) := lt_depreciacion_info_rec; 
                                    
                                else
                                    P_OUTPUT('<DISMIN>'||ln_credito||'</DISMIN>');
                                    P_OUTPUT('<ADICION>'||ln_debito||'</ADICION>');
                                end if; 
                                close get_saldo_info; 
                                
                          P_OUTPUT('</GRUPO>');
                    END LOOP;
                 CLOSE get_descr_info;
                 
                 
        P_OUTPUT('<AGRUPADO>'||ls_agrupado||'</AGRUPADO>');
        P_OUTPUT('<SUB_INICIAL>'||ln_subtotal_inicial||'</SUB_INICIAL>');   
        P_OUTPUT('<SUB_FINAL>'||ln_subtotal_final||'</SUB_FINAL>');   
        P_OUTPUT('<SUB_PTD>'||ln_subtotal_ptd||'</SUB_PTD>');
        
        if ls_agrupado = 'INVERSION' then
        lt_subtotal_inversion_info_rec.agrupado := ls_agrupado; 
        lt_subtotal_inversion_info_rec.saldo_inicial := ln_subtotal_inicial; 
        lt_subtotal_inversion_info_rec.saldo_final := ln_subtotal_final; 
        lt_subtotal_inversion_info_rec.suma := ln_subtotal_ptd;
        
        ltt_inversion_set_rec.et_inversion_tbl := lt_inversion_tbl;
        ltt_inversion_set_rec.et_subtotal_agrupado_rec := lt_subtotal_inversion_info_rec;
        end if;
        
        if ls_agrupado = 'MF' then
            lt_subtotal_mf_info_rec.agrupado := ls_agrupado; 
            lt_subtotal_mf_info_rec.saldo_inicial := ln_subtotal_inicial; 
            lt_subtotal_mf_info_rec.saldo_final := ln_subtotal_final; 
            lt_subtotal_mf_info_rec.suma := ln_subtotal_ptd;
            
            ltt_moneda_funcional_set_rec.et_moneda_funcional_tbl := lt_moneda_funcional_tbl;
            ltt_moneda_funcional_set_rec.et_subtotal_agrupado_rec :=lt_subtotal_mf_info_rec;
        end if;

        if ls_agrupado = 'DPN' then
        lt_subtotal_dpn_info_rec.agrupado := ls_agrupado; 
        lt_subtotal_dpn_info_rec.saldo_inicial := ln_subtotal_inicial; 
        lt_subtotal_dpn_info_rec.saldo_final := ln_subtotal_final; 
        lt_subtotal_dpn_info_rec.suma := ln_subtotal_ptd;
        
        ltt_depreciacion_set_rec.et_depreciacion_tbl := lt_depreciacion_tbl;
        ltt_depreciacion_set_rec.et_subtotal_agrupado_rec := lt_subtotal_dpn_info_rec;
        end if;

        ln_total_inicial := ln_total_inicial + ln_subtotal_inicial; 
        ln_total_ptd := ln_total_ptd + ln_subtotal_ptd;
        ln_total_final := ln_total_final + ln_subtotal_final; 
        P_OUTPUT('</BLOQUE>');         
        end loop;        
         close get_agrupado_info;   
         P_OUTPUT('<VNL_INICIAL>'||ln_total_inicial||'</VNL_INICIAL>');
         P_OUTPUT('<VNL_FINAL>'||ln_total_final||'</VNL_FINAL>');
         P_LOG('VNL_INICIAL:'||ln_total_inicial);
         P_OUTPUT('<PTD_FINAL>'||ln_total_ptd||'</PTD_FINAL>');
         
         lt_subtotal_vnl_info_rec.saldo_inicial := ln_total_inicial;
         lt_subtotal_vnl_info_rec.suma := ln_total_ptd;
         lt_subtotal_vnl_info_rec.saldo_final := ln_total_final;
         
         ltt_by_rubro_rec.et_inversion_set_rec := ltt_inversion_set_rec;
         ltt_by_rubro_rec.et_moneda_funcional_set_rec := ltt_moneda_funcional_set_rec;
         ltt_by_rubro_rec.et_depreciacion_set_rec := ltt_depreciacion_set_rec;
         ltt_by_rubro_rec.et_subtotal_vnl_rec := lt_subtotal_vnl_info_rec; 
         /*
         dbms_output.put_line('First inversion:'||lt_inversion_tbl.first); 
         dbms_output.put_line('Last inversion:'||lt_inversion_tbl.last); 
         dbms_output.put_line('First MF:'||lt_moneda_funcional_tbl.first); 
         dbms_output.put_line('Last MF:'||lt_moneda_funcional_tbl.last); 
         dbms_output.put_line('First depre:'||lt_depreciacion_tbl.first);
         dbms_output.put_line('Last depre:'||lt_depreciacion_tbl.last); */

         for i in lt_inversion_tbl.first .. lt_inversion_tbl.last loop
                lt_inversion_info_rec := lt_inversion_tbl(i); 
                dbms_output.put_line(lt_inversion_info_rec.rubro||chr(9)
                ||lt_inversion_info_rec.num_rubro||chr(9)
                ||lt_inversion_info_rec.cuenta||'-'
                ||lt_inversion_info_rec.subcuenta||chr(9)
                ||lt_inversion_info_rec.concepto||chr(9)
                ||lt_inversion_info_rec.saldo_inicial||chr(9)
                ||NVL(lt_inversion_info_rec.ad_altas,0)||chr(9)  
                ||NVL(lt_inversion_info_rec.ad_dism_inversa,0)||chr(9)
                ||NVL(lt_inversion_info_rec.suma,0)||chr(9)
                ||NVL(lt_inversion_info_rec.saldo_final,0));
         end loop; 
         
         dbms_output.put_line('lt_subtotal_inversion_info_rec.agrupado:'||lt_subtotal_inversion_info_rec.agrupado||chr(9)
                               ||'lt_subtotal_inversion_info_rec.saldo_inicial:'||lt_subtotal_inversion_info_rec.saldo_inicial||chr(9)
                               ||'lt_subtotal_inversion_info_rec.suma:'||lt_subtotal_inversion_info_rec.suma||chr(9)
                               ||'lt_subtotal_inversion_info_rec.saldo_final:'||lt_subtotal_inversion_info_rec.saldo_final);
         dbms_output.put_line(' ');
         for i in lt_moneda_funcional_tbl.first .. lt_moneda_funcional_tbl.last loop
                lt_moneda_funcional_info_rec := lt_moneda_funcional_tbl(i); 
                dbms_output.put_line(lt_moneda_funcional_info_rec.rubro||chr(9)
                ||lt_moneda_funcional_info_rec.num_rubro||chr(9)
                ||lt_moneda_funcional_info_rec.cuenta||'-'
                ||lt_moneda_funcional_info_rec.subcuenta||chr(9)
                ||lt_moneda_funcional_info_rec.concepto||chr(9)
                ||lt_moneda_funcional_info_rec.saldo_inicial||chr(9)
                ||NVL(lt_moneda_funcional_info_rec.ad_altas,0)||chr(9)  
                ||NVL(lt_moneda_funcional_info_rec.ad_dism_inversa,0)||chr(9)
                ||NVL(lt_moneda_funcional_info_rec.suma,0)||chr(9)
                ||NVL(lt_moneda_funcional_info_rec.saldo_final,0)||chr(9));
         end loop; 
          dbms_output.put_line('lt_subtotal_mf_info_rec.agrupado:'||lt_subtotal_mf_info_rec.agrupado||chr(9)
                               ||'lt_subtotal_mf_info_rec.saldo_inicial:'||lt_subtotal_mf_info_rec.saldo_inicial||chr(9)
                               ||'lt_subtotal_mf_info_rec.suma:'||lt_subtotal_mf_info_rec.suma||chr(9)
                               ||'lt_subtotal_mf_info_rec.saldo_final:'||lt_subtotal_mf_info_rec.saldo_final||chr(9));
          dbms_output.put_line(' ');
         
         for i in lt_depreciacion_tbl.first .. lt_depreciacion_tbl.last loop
                lt_depreciacion_info_rec := lt_depreciacion_tbl(i); 
                dbms_output.put_line(lt_depreciacion_info_rec.rubro||chr(9)
                ||lt_depreciacion_info_rec.num_rubro||chr(9)
                ||lt_depreciacion_info_rec.cuenta||'-'
                ||lt_depreciacion_info_rec.subcuenta||chr(9)
                ||lt_depreciacion_info_rec.concepto||chr(9)
                ||lt_depreciacion_info_rec.saldo_inicial||chr(9)
                ||NVL(lt_depreciacion_info_rec.ad_altas,0)||chr(9)  
                ||NVL(lt_depreciacion_info_rec.ad_dism_inversa,0)||chr(9)
                ||NVL(lt_depreciacion_info_rec.suma,0)||chr(9)
                ||NVL(lt_depreciacion_info_rec.saldo_final,0)||chr(9));
         end loop; 
          dbms_output.put_line('lt_subtotal_dpn_info_rec.agrupado:'||lt_subtotal_dpn_info_rec.agrupado||chr(9)
                                ||'lt_subtotal_dpn_info_rec.saldo_inicial:'||lt_subtotal_dpn_info_rec.saldo_inicial||chr(9)
                                ||'lt_subtotal_dpn_info_rec.suma:'||lt_subtotal_dpn_info_rec.suma||chr(9)
                                ||'lt_subtotal_dpn_info_rec.saldo_final:'||lt_subtotal_dpn_info_rec.saldo_final);
          dbms_output.put_line('-');
          dbms_output.put_line(lt_subtotal_vnl_info_rec.saldo_inicial||chr(9)
                          ||lt_subtotal_vnl_info_rec.suma||chr(9)
                          ||lt_subtotal_vnl_info_rec.saldo_final);


         P_LOG('VNL_FINAL:'||ln_total_final);
         P_LOG('Fin de programa');
         P_OUTPUT('</XXGAM_SAF_RUBRO6_PKG>');
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         P_LOG ('PROCEDURE:' || 'MAIN');
      WHEN OTHERS
      THEN
         pso_errmsg := 'Exception others: ' || SQLERRM || ',' || SQLCODE;
         pso_errcod := '2';
         P_LOG ('PROCEDURE:' || 'MAIN');
         P_LOG ('Excepcion Programa:' || pso_errmsg);
   END main;
   
   
    PROCEDURE execute_rubro (pso_errmsg         OUT VARCHAR2
                           ,pso_errcod          OUT VARCHAR2
                           ,psi_operating_unit  in  varchar2
                           ,psi_periodo         in  varchar2
                           ,psi_divisa          in  varchar2
                           ,pro_tt_by_rubro_rec out XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec
                           ) is 
    /**** -Primer cursor muestra INVERSIÓN, DPRN Y MF de XXGAM_SAF_SETUP- ****/   
   cursor get_agrupado_info
   is 
        select   DISTINCT AGRUPADO grupo 
          FROM   XXGAM_SAF_SETUP
         WHERE   ID_RUBRO = '6';
   agrupado_info_rec    get_agrupado_info%ROWTYPE;   
   
/**** -Segundo cursor muestra la primera parte de la sumaria- *****/
/*** este sursosr toma como parametro el ls_agrupado del primer cursor  */
      CURSOR get_descr_info(ls_agrupado varchar2)
      IS
        SELECT   rubro rubro
                ,id_rubro num_rubro
                ,cuenta p_cuenta
                ,subcuenta p_subcuenta
                ,cuenta||'-'||subcuenta cuenta
                ,descripcion_cuenta||'-'||descripcion_subcuenta concepto
        FROM   XXGAM_SAF_SETUP
       WHERE   1 = 1
               and id_rubro = '6'
               and agrupado = ls_agrupado;
               
   descr_info_rec   get_descr_info%ROWTYPE;
   
/**** Tercer cursor que muestra la información de los acumulados  YTD PTD*****/
/** Este cursosr toma como parametro la cuenta, subcuenta y el periodo **/
   cursor get_saldo_info (ls_cuenta            varchar2
                        , ls_subcuenta         varchar2
                        , periodo              varchar2
                        --.DIVISA
                        )
   is
        SELECT LG.NAME LEDGER,
            SEGMENT1 || '-' || 
            SEGMENT2 || '-' || 
            SEGMENT3 || '-' || 
            SEGMENT4 || '-' || 
            SEGMENT5 || '-' || 
            SEGMENT6 || '-' || 
            SEGMENT7 || '-' || 
            SEGMENT8 ACCOUNT,
            LT.PERIOD_NAME PERIOD,
            LG.CURRENCY_CODE CURRENCY,
            DECODE (
                'A',
                'E', DECODE (
                        BA.currency_code,
                        LG.currency_code, DECODE (
                                              BA.actual_flag,
                                              'A', (NVL (
                                                       BA.period_net_dr_beq,
                                                       0)
                                                    - NVL (
                                                         BA.period_net_cr_beq,
                                                         0)),
                                              (NVL (BA.period_net_dr, 0)
                                               - NVL (BA.period_net_cr, 0))),
                        (NVL (BA.period_net_dr, 0)
                         - NVL (BA.period_net_cr, 0))),
                (NVL (BA.period_net_dr, 0) - NVL (BA.period_net_cr, 0))) PTD,
            DECODE (
                 BA.currency_code,
                 LG.currency_code, NULL,
                 'STAT', NULL,
                 DECODE (
                    LR.relationship_type_code,
                    'BALANCE', NULL,
                    DECODE (
                       BA.translated_flag,
                       'R', DECODE (
                               BA.actual_flag,
                               'A', (NVL (BA.period_net_dr_beq, 0)
                                     - NVL (BA.period_net_cr_beq, 0)),
                               NULL),
                       NULL))) PTD_CONVERTED,
            DECODE (
                'A',
                'E', DECODE (
                        BA.currency_code,
                        LG.currency_code, DECODE (
                                              BA.actual_flag,
                                              'A', ( (NVL (
                                                         BA.
                                                          begin_balance_dr_beq,
                                                         0)
                                                      - NVL (
                                                           BA.
                                                            begin_balance_cr_beq,
                                                           0))
                                                    + (NVL (
                                                          BA.
                                                           period_net_dr_beq,
                                                          0)
                                                       - NVL (
                                                            BA.
                                                             period_net_cr_beq,
                                                            0))),
                                              ( (NVL (BA.begin_balance_dr, 0)
                                                 - NVL (BA.begin_balance_cr,
                                                        0))
                                               + (NVL (BA.period_net_dr, 0)
                                                  - NVL (BA.period_net_cr, 0)))),
                        ( (NVL (BA.begin_balance_dr, 0)
                           - NVL (BA.begin_balance_cr, 0))
                         + (NVL (BA.period_net_dr, 0)
                            - NVL (BA.period_net_cr, 0)))),
                ( (NVL (BA.begin_balance_dr, 0)
                   - NVL (BA.begin_balance_cr, 0))
                 + (NVL (BA.period_net_dr, 0) - NVL (BA.period_net_cr, 0)))) YTD,
          DECODE (
                 BA.currency_code,
                 LG.currency_code, NULL,
                 'STAT', NULL,
                 DECODE (
                    LR.relationship_type_code,
                    'BALANCE', NULL,
                    DECODE (
                       BA.translated_flag,
                       'R', DECODE (
                               BA.actual_flag,
                               'A', ( (NVL (BA.begin_balance_dr_beq, 0)
                                       - NVL (BA.begin_balance_cr_beq, 0))
                                     + (NVL (BA.period_net_dr_beq, 0)
                                        - NVL (BA.period_net_cr_beq, 0))),
                               NULL),
                       NULL))) YTD_CONVERTED,
                       CC.code_combination_id code_cuenta  
FROM GL_LEDGERS LG, 
          GL_CODE_COMBINATIONS CC,
          GL_PERIODS LT,
          --Empiezan tablas extras
          GL_BALANCES BA,
          GL_LEDGER_RELATIONSHIPS LR
          --Terminan tablas extras
WHERE 1=1
            AND LG.CHART_OF_ACCOUNTS_ID = CC.CHART_OF_ACCOUNTS_ID
            AND LG.NAME=psi_divisa
            AND LG.PERIOD_SET_NAME=LT.PERIOD_SET_NAME
            --Empiezan filtros extras
            AND BA.CODE_COMBINATION_ID=CC.CODE_COMBINATION_ID
            AND BA.PERIOD_NAME=LT.PERIOD_NAME
            AND BA.CURRENCY_CODE=LG.CURRENCY_CODE
            AND BA.LEDGER_ID=LG.LEDGER_ID
            AND LR.SOURCE_LEDGER_ID=LR.TARGET_LEDGER_ID
            AND LG.LEDGER_ID=LR.TARGET_LEDGER_ID
            AND LR.TARGET_CURRENCY_CODE=LG.CURRENCY_CODE
            --Terminan filtros extras
            --AND ROWNUM<10000
            AND SEGMENT1=psi_operating_unit /*'02'          cur_operating_unit */
            AND SEGMENT2='00'
            AND SEGMENT3='000000'
            AND SEGMENT4='0000'
            AND SEGMENT5 = ls_cuenta
            AND SEGMENT6 = ls_subcuenta
            AND SEGMENT7='0000'
            AND SEGMENT8='00'
            AND LT.PERIOD_NAME = periodo
            AND BA.ACTUAL_FLAG='A'
            --AND LG.LEDGER_ID='2021'
ORDER BY SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5, SEGMENT6, SEGMENT7, SEGMENT8;
     
    saldo_info_rec    get_saldo_info%ROWTYPE;
   
   ---Declaracion de variables------
   ls_agrupado          varchar2(32767); 
   ls_cuenta            varchar2(32767); 
   ls_subcuenta         varchar2(32767); 
   ln_subtotal_inicial  number; 
   ln_total_inicial     number;
   ln_subtotal_final    number; 
   ln_total_final       number; 
   
   --ls_periodo varchar2(32767);
   ls_periodo_anterior  varchar2(32767);
   ln_subtotal_ptd      number;  
   ln_total_ptd         number; 
   ln_debito            number; 
   ln_credito           number;   
   ln_transfer          number;  
   ln_depre             number;    
   
   /*** Variables para el package maestro ******/
   ln_inicial_ytd       number;  
   /** subtotales de columna adiciones **/
   ln_sub_adicion_inv   number;
   ln_sub_adicion_mf    number;
   ln_sub_adicion_dpn   number;
   /** subtotales de columna dism. inv. **/
   ln_sub_disinv_inv    number;
   ln_sub_disinv_mf     number;
   ln_sub_disinv_dpn    number;
      /** subtotales de columna transferencia **/
   ln_sub_transf_inv    number;
   ln_sub_transf_mf     number;
   ln_sub_transf_dpn    number;
   /** subtotales de columna baja_MOI_sin_ingresos **/
   ln_sub_baja_sin_ingreso_inv  number;
   ln_sub_baja_sin_ingreso_mf   number;
   ln_sub_baja_sin_ingreso_dpn  number;
   /*subtotales de columna baja OI x venta**/
   ln_sub_baja_x_venta_inv      number;
   ln_sub_baja_x_venta_mf       number;
   ln_sub_baja_x_venta_dpn      number;
   /** subtotales de columna baja por depreciacion sin ingreso ***/
   ln_sub_deprn_sin_ingreso_inv number;
   ln_sub_deprn_sin_ingreso_mf  number;
   ln_sub_deprn_sin_ingreso_dpn number;
   /** subtotales de colunma baja por depreciacion X venta **/
   ln_sub_deprn_x_venta_inv     number;
   ln_sub_deprn_x_venta_mf      number;
   ln_sub_deprn_x_venta_dpn     number;
   /***subtotales de columna dpn sin ingreso*/
   ln_sub_dpn_sin_ingreso_inv   number;
   ln_sub_dpn_sin_ingreso_mf    number;
   ln_sub_dpn_sin_ingreso_dpn   number;
   /***subtotales de columna dpn X venta*/
   ln_sub_dpn_x_venta_inv       number;
   ln_sub_dpn_x_venta_mf        number;
   ln_sub_dpn_x_venta_dpn       number;
   /** subtotales de columna depreciacion del ejercicio **/ 
   ln_sub_depeje_inv            number;
   ln_sub_depeje_mf             number;
   ln_sub_depeje_dpn            number;
   /** totales de fila VNL **/
   ln_vnl_adicion               number;
   ln_vnl_disinv                number;
   ln_vnl_transfer              number;
   ln_vnl_baja_sin_ingreso      number;
   ln_vnl_baja_x_venta          number;
   ln_vnl_dpn_sin_ingreso       number;
   ln_vnl_dpn_x_venta           number;
   ln_vnl_depeje                number;
   
   ln_final_ytd                 number;  
   ln_suma_ptd                  number;  
   
   lt_inversion_info_rec                XXGAM_SAF_OP_MEN_PKG.t_inversion_rec;                ---variable record para inversion
   lt_moneda_funcional_info_rec         XXGAM_SAF_OP_MEN_PKG.t_moneda_funcional_rec;  ---variable record para moneda funcional    
   lt_depreciacion_info_rec             XXGAM_SAF_OP_MEN_PKG.t_depreciacion_rec;          ---variable record para depreciacion
   
   lt_subtotal_inversion_info_rec       XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de inversion
   lt_subtotal_mf_info_rec              XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de MF
   lt_subtotal_dpn_info_rec             XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de depreciación
   
   lt_subtotal_vnl_info_rec             XXGAM_SAF_OP_MEN_PKG.t_subtotal_vnl_rec;          ---variable record para total vnl
                                      
   lt_inversion_tbl                     XXGAM_SAF_OP_MEN_PKG.t_inversion_tbl;            ---variables tipo tabla para inversión
   lt_moneda_funcional_tbl              XXGAM_SAF_OP_MEN_PKG.t_moneda_funcional_tbl;     ---variables tipo tabla para MF
   lt_depreciacion_tbl                  XXGAM_SAF_OP_MEN_PKG.t_depreciacion_tbl;         ---variables tipo tabla para depreciación
   
   ltt_inversion_set_rec                XXGAM_SAF_OP_MEN_PKG.t_inversion_set_rec;        ---variable tipo set inversion para inversión
   ltt_moneda_funcional_set_rec         XXGAM_SAF_OP_MEN_PKG.t_moneda_funcional_set_rec; ---variable tipo set moneda para MF
   ltt_depreciacion_set_rec             XXGAM_SAF_OP_MEN_PKG.t_depreciacion_set_rec;     ---variable tipo set depreciacion para depreciación     
   
   ltt_by_rubro_rec                     XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;     ---variable tipo rubro
      
    LT_CATEGORY_TBL                     XXGAM_SAF_UTIL_V1_PKG.T_CATEGORY_TBL;
    ln_costo_x_venta            number := 0; 
    ln_costo_scrap              number := 0; 

    ln_deprn_x_venta            number :=0;
    ln_deprn_scrap              number :=0;
    
    /** Variables de dolares **/
    ln_divisa_usd               number;
    ln_divisa_mxn               number;
    
    ln_baja_sin_ingreso_usd     number;
    ln_baja_x_venta_usd         number;
    
    ln_deprn_x_venta_usd        number;
    ln_deprn_sin_ingreso_usd    number;
    
    ls_errmsg                   varchar2(2000); 
    ls_errcod                   varchar2(2000); 
    
    /********************************************/
    
    ln_valor_original_mxn       number := 0; 
    ln_sub_val_orig_mxn         number := 0; 
    ln_depren_ejercicio         number := 0;
    ln_sub_deprn_ejerc          number := 0; 
    
    ln_deprn_saldo_inicial      number := 0; 
    ln_deprn_saldo_final        number := 0; 
    ln_deprn_subtotal_inicial   number := 0; 
    ln_deprn_subtotal_final   number := 0;
    
    /** Ln_diferencia_propios_vs_arrendados **/
    ln_dif_prop_vs_arrend       number := 5460036.68; 
                         
    begin 
        dbms_output.put_line('INICIO DE RUBRO 6');
        /************/
         LT_CATEGORY_TBL(1) := 'MEJORAS PROPIEDADES ARRENDADAS-TERRENOS-AJENOS';
         LT_CATEGORY_TBL(2) := 'MEJORAS PROPIEDADES ARRENDADAS-TERRENOS-FEDERALES';
        /**  LT_CATEGORY_TBL(3) := 'MEJORAS PROPIEDADES ARRENDADAS-TERRENOS-AJENO_S';  NA **/
          /********************/
          
        if psi_divisa = 'GAM_MXN' then
            select  gl.ledger_id
            into  ln_divisa_mxn
            from  gl_ledgers gl
            where  gl.name = psi_divisa;
        else
            select  gl.ledger_id
            into  ln_divisa_usd
            from  gl_ledgers gl
            where  gl.name = psi_divisa;
        end if;     
  
              
     fnd_file.put_line(fnd_file.log,'******************************************');  
     fnd_file.put_line(fnd_file.log,'Comienza Ejecuta RUBRO6');  
    
    select   period_name 
    into   ls_periodo_anterior
    from   gl_periods
    where   1 = 1
           and period_set_name = 'GAM'
           and   period_name not like 'AJU%'
           and END_DATE  in (select   start_date -1
                             from   gl_periods
                            where   1 = 1  
                                    and   period_set_name = 'GAM'
                                    and   period_name = psi_periodo);
                                    
   ln_total_inicial := 0;
   ln_total_final := 0;
   ln_total_ptd := 0; 
   ln_vnl_adicion :=0;
   ln_vnl_disinv :=0;
   ln_vnl_transfer :=0;
   ln_vnl_baja_sin_ingreso :=0;
   ln_vnl_baja_x_venta :=0;
   ln_vnl_depeje :=0;
   
   
   ln_sub_val_orig_mxn := 0; 
   
      open get_agrupado_info();
      loop
            fetch get_agrupado_info into agrupado_info_rec;
            exit when get_agrupado_info%notfound;
            ls_agrupado := agrupado_info_rec.grupo;
            
            ln_subtotal_inicial := 0;
            
            ln_sub_adicion_inv :=0;
            ln_sub_adicion_mf :=0;
            ln_sub_adicion_dpn :=0;
            ln_sub_disinv_inv :=0;
            ln_sub_disinv_mf :=0;
            ln_sub_disinv_dpn :=0;
            ln_sub_baja_sin_ingreso_inv :=0;
            ln_sub_baja_sin_ingreso_mf :=0;
            ln_sub_baja_sin_ingreso_dpn :=0;
            ln_sub_baja_x_venta_inv :=0;
            ln_sub_baja_x_venta_mf :=0;
            ln_sub_baja_x_venta_dpn :=0;
            ln_sub_deprn_sin_ingreso_dpn :=0;
            ln_sub_deprn_x_venta_dpn :=0;
            ln_sub_depeje_inv :=0;
            ln_sub_depeje_mf :=0;
            ln_sub_depeje_dpn :=0;
   
   
            ln_subtotal_final := 0;
            ln_subtotal_ptd := 0;
            OPEN get_descr_info(ls_agrupado);
            LOOP
                    FETCH get_descr_info INTO descr_info_rec;
                    EXIT WHEN get_descr_info%NOTFOUND;
                          ls_cuenta := descr_info_rec.p_cuenta;
                          ls_subcuenta := descr_info_rec.p_subcuenta;
                          /*** Obtiene el acumulado del periodo anterior al que ingreso el usuario ***/
                                OPEN get_saldo_info(ls_cuenta, ls_subcuenta, ls_periodo_anterior);--,psi_operating_unit); -- CHECAR psi_operating_unit
                                loop
                                        fetch get_saldo_info into saldo_info_rec;
                                        ln_inicial_ytd := saldo_info_rec.YTD;
                                        ln_subtotal_inicial := ln_subtotal_inicial + saldo_info_rec.YTD;
                                        exit;
                                end loop;
                                close get_saldo_info;      
                                /** obtiene el acumulado al periodo que ingreso el usuario **/
                                OPEN get_saldo_info(ls_cuenta, ls_subcuenta, psi_periodo);--,psi_operating_unit);   -- CHECAR psi_operating_unit
                                loop
                                        fetch get_saldo_info into saldo_info_rec;
                                        ln_final_ytd := saldo_info_rec.YTD;
                                        ln_subtotal_final := ln_subtotal_final + saldo_info_rec.YTD;
                                        ln_suma_ptd := saldo_info_rec.PTD;
                                        ln_subtotal_ptd := ln_subtotal_ptd + saldo_info_rec.PTD;
                                        
                                        /** Revisar Altas y disminucion inversa para rubro Mejoras Propiedades Arrendadas **/
                                        
                                        if psi_divisa = 'GAM_MXN' then
                                            ln_debito := 0;  /** XXGAM_SAF_UTIL_V1_PKG.ADDITION(saldo_info_rec.code_cuenta,psi_periodo,ln_divisa_mxn); **/
                                            ln_credito := 0; /** XXGAM_SAF_UTIL_V1_PKG.REDUCTION(saldo_info_rec.code_cuenta,psi_periodo,ln_divisa_mxn); **/
                                        else 
                                            ln_debito := 0; /** XXGAM_SAF_UTIL_V1_PKG.ADDITION(saldo_info_rec.code_cuenta,psi_periodo,ln_divisa_usd); **/
                                            ln_credito :=0; /** XXGAM_SAF_UTIL_V1_PKG.REDUCTION(saldo_info_rec.code_cuenta,psi_periodo,ln_divisa_usd); **/
                                        end if;    
                                        
                                        exit;
                                end loop;
                                
                                /** informacion inversion_rec **/
                                if ls_agrupado = 'INVERSION' then
                                 
                                    ln_valor_original_mxn := 0; 
                                     if psi_divisa = 'GAM_MXN' then
                                     APPS.XXGAM_SAF_UTIL_V1_PKG.GET_SDO_VALOR_ORIGINAL_MXN ( PSO_ERRMSG            => ls_errmsg
                                                                                        , PSO_ERRCOD              => ls_errcod
                                                                                        , PSI_BOOK_CODE           => '02_AMX_CONTABLE'
                                                                                        , PSI_PERIOD_NAME         => psi_periodo
                                                                                        , PTI_CATEGORY_TBL        => LT_CATEGORY_TBL
                                                                                        , PSI_CUENTA_INV          => ls_cuenta
                                                                                        , PSI_SUBCUENTA_INV       => ls_subcuenta
                                                                                        , PNO_VALOR_ORIGINAL_MXN  => ln_valor_original_mxn
                                                                                        );
                                     end if;            
                                
                                    ln_sub_val_orig_mxn := ln_sub_val_orig_mxn + ln_valor_original_mxn; 
                                   
                                    lt_inversion_info_rec.rubro := descr_info_rec.rubro;
                                    lt_inversion_info_rec.num_rubro := descr_info_rec.num_rubro;
                                    lt_inversion_info_rec.cuenta := descr_info_rec.p_cuenta;
                                    lt_inversion_info_rec.subcuenta := descr_info_rec.p_subcuenta;
                                    lt_inversion_info_rec.concepto := descr_info_rec.concepto;
                                    lt_inversion_info_rec.saldo_inicial := ln_valor_original_mxn; /** ln_inicial_ytd**/
                                    lt_inversion_info_rec.ad_altas := nvl(ln_debito,0);
                                    lt_inversion_info_rec.ad_dism_inversa :=  nvl(ln_credito,0);
                                    lt_inversion_info_rec.ad_transferencia := 0;
                                   /** lt_inversion_info_rec.saldo_final := ln_valor_original_mxn;  ** ln_final_ytd;**/
                                    
                                    /** codigo para la parte de MOI bajas por scrap y X venta**/
                                    APPS.XXGAM_SAF_UTIL_V1_PKG.GET_RETIREMENT_INFO ( PSO_ERRMSG            => PSO_ERRMSG 
                                                                                 , PSO_ERRCOD           => PSO_ERRCOD
                                                                                 , PSI_OPERATING_UNIT   => PSI_OPERATING_UNIT
                                                                                 , PSI_PERIOD_NAME      => psi_periodo /* PSI_PERIOD_NAME */
                                                                                 , psi_cuenta           => ls_cuenta  /** psi_cuenta**/
                                                                                 , psi_sub_cuenta       => ls_subcuenta /** psi_sub_cuenta **/
                                                                                 , PTI_CATEGORY_TBL     => LT_CATEGORY_TBL
                                                                                 , pno_costo_x_venta    => ln_costo_x_venta
                                                                                 , pno_costo_scrap      => ln_costo_scrap
                                                                                 , pno_costo_scrap_usd      => ln_baja_sin_ingreso_usd
                                                                                 , pno_costo_x_venta_usd    => ln_baja_x_venta_usd 
                                                                                 );
                                    
                                    if psi_divisa = 'GAM_MXN' then
                                        lt_inversion_info_rec.ret_moi_sin_ingr := (-1)*ln_costo_scrap;
                                        lt_inversion_info_rec.ret_moi_x_venta  := (-1)*ln_costo_x_venta;
                                    else    
                                        lt_inversion_info_rec.ret_moi_sin_ingr := (-1)*ln_baja_sin_ingreso_usd;
                                        lt_inversion_info_rec.ret_moi_x_venta  := (-1)*ln_baja_x_venta_usd;
                                    end if;    
                                     /****************************************************/                                   
                                    
                                    
                                    
                                     /*  Se modifica por que se agrega otra variable

                                    ln_sub_adicion_inv :=ln_sub_adicion_inv+NVL(ln_debito,0);
                                    ln_sub_disinv_inv := ln_sub_disinv_inv+ nvl(ln_credito,0);
                                    ln_sub_depeje_inv :=0;*/
                                    
                                    ln_sub_adicion_inv  := ln_sub_adicion_inv + nvl(lt_inversion_info_rec.ad_altas,0);
                                    ln_sub_disinv_inv   := ln_sub_disinv_inv + nvl(lt_inversion_info_rec.ad_dism_inversa,0);
                                    ln_sub_transf_inv   := 0;/**    NVL(ln_debito,0) + nvl(ln_credito,0); pendiente **/
                                    ln_sub_baja_sin_ingreso_inv := ln_sub_baja_sin_ingreso_inv + lt_inversion_info_rec.ret_moi_sin_ingr;   
                                    ln_sub_baja_x_venta_inv     := ln_sub_baja_x_venta_inv +  lt_inversion_info_rec.ret_moi_x_venta; 
                                    ln_sub_depeje_inv :=0;                               
                                   
                                    lt_inversion_info_rec.suma := nvl(lt_inversion_info_rec.ad_altas,0) + nvl(lt_inversion_info_rec.ad_dism_inversa,0); 
                                    lt_inversion_info_rec.suma := nvl(lt_inversion_info_rec.suma,0) + nvl(lt_inversion_info_rec.ad_transferencia,0)+ nvl(lt_inversion_info_rec.ret_moi_sin_ingr,0)+nvl(lt_inversion_info_rec.ret_moi_x_venta,0); 
                                    
                                    lt_inversion_info_rec.saldo_final := lt_inversion_info_rec.saldo_inicial + lt_inversion_info_rec.suma; 
                                    
                                    lt_inversion_tbl(get_descr_info%ROWCOUNT) := lt_inversion_info_rec;
                                       
                                    
                                end if;      
                                
                                 /** informacion ms_rec **/
                                if ls_agrupado = 'MF' then
                                    lt_moneda_funcional_info_rec.rubro := descr_info_rec.rubro;
                                    lt_moneda_funcional_info_rec.num_rubro := descr_info_rec.num_rubro;
                                    lt_moneda_funcional_info_rec.cuenta := descr_info_rec.p_cuenta;
                                    lt_moneda_funcional_info_rec.subcuenta := descr_info_rec.p_subcuenta;
                                    lt_moneda_funcional_info_rec.concepto := descr_info_rec.concepto;
                                    lt_moneda_funcional_info_rec.saldo_inicial := ln_inicial_ytd;
                                    lt_moneda_funcional_info_rec.ad_altas := nvl(ln_debito,0)-nvl(ln_credito,0); /*nvl(ln_credito,0); exclusivo del rubro */
                                    lt_moneda_funcional_info_rec.ad_dism_inversa := 0; /*nvl(ln_credito,0); exclusivo del rubro */
                                    lt_moneda_funcional_info_rec.ad_transferencia := 0;
                                    lt_moneda_funcional_info_rec.ret_moi_sin_ingr :=0;
                                    lt_moneda_funcional_info_rec.suma := ln_suma_ptd;
                                    lt_moneda_funcional_info_rec.saldo_final := ln_final_ytd;
                                    
                                    lt_moneda_funcional_tbl(get_descr_info%ROWCOUNT) := lt_moneda_funcional_info_rec;
                                     
                                     ln_sub_adicion_mf :=ln_sub_adicion_mf+nvl(ln_debito,0) - nvl(ln_credito,0);
                                    ln_sub_disinv_mf := 0;
                                    ln_sub_transf_mf := 0;
                                    ln_sub_baja_sin_ingreso_mf :=0;
                                    ln_sub_depeje_mf :=0;
   
            
            
   
                                    

                                end if;      
                                
                                
                                if ls_agrupado = 'DPN' then
                                
                                    IF PSI_DIVISA='GAM_MXN' THEN
                                    XXGAM_SAF_UTIL_V1_PKG.get_deprn_ejercicio_mxn(pso_errmsg             => ls_errmsg
                                                                                  ,pso_errcod            => ls_errcod
                                                                                  ,psi_book_code         => '02_AMX_CONTABLE' 
                                                                                  ,psi_operating_unit    => PSI_OPERATING_UNIT
                                                                                  ,psi_period_name       => psi_periodo
                                                                                  ,pti_category_tbl      => LT_CATEGORY_TBL
                                                                                  ,psi_cuenta_deprn      => ls_cuenta
                                                                                  ,psi_subcuenta_deprn   => ls_subcuenta
                                                                                  ,pno_depren_ejercicio  => ln_depren_ejercicio
                                                                                  ); 
                                    
                                    APPS.XXGAM_SAF_UTIL_V1_PKG.GET_DEPRN_SALDO_MXN ( PSO_ERRMSG            => LS_ERRMSG
                                                                                   , PSO_ERRCOD            => LS_ERRCOD
                                                                                   , PSI_BOOK_CODE         => '02_AMX_CONTABLE' 
                                                                                   , PSI_PERIOD_NAME       => ls_periodo_anterior
                                                                                   , PTI_CATEGORY_TBL      => LT_CATEGORY_TBL
                                                                                   , PSI_CUENTA_DEPRN      => ls_cuenta
                                                                                   , PSI_SUBCUENTA_DEPRN   => ls_subcuenta
                                                                                   , PNO_SALDO_MXN         => ln_deprn_saldo_inicial
                                                                                    );                                                  
                                                                                  
                                    APPS.XXGAM_SAF_UTIL_V1_PKG.GET_DEPRN_SALDO_MXN ( PSO_ERRMSG            => LS_ERRMSG
                                                                                   , PSO_ERRCOD            => LS_ERRCOD
                                                                                   , PSI_BOOK_CODE         => '02_AMX_CONTABLE' 
                                                                                   , PSI_PERIOD_NAME       => psi_periodo
                                                                                   , PTI_CATEGORY_TBL      => LT_CATEGORY_TBL
                                                                                   , PSI_CUENTA_DEPRN      => ls_cuenta
                                                                                   , PSI_SUBCUENTA_DEPRN   => ls_subcuenta
                                                                                   , PNO_SALDO_MXN         => ln_deprn_saldo_final
                                                                                    );                                             
                                                                                  
                                    END IF; 
                                    
                                    
                                    lt_depreciacion_info_rec.rubro := descr_info_rec.rubro;
                                    lt_depreciacion_info_rec.num_rubro := descr_info_rec.num_rubro;
                                    lt_depreciacion_info_rec.cuenta := descr_info_rec.p_cuenta;
                                    lt_depreciacion_info_rec.subcuenta := descr_info_rec.p_subcuenta;
                                    lt_depreciacion_info_rec.concepto := descr_info_rec.concepto;
                                    
                                    /** lt_depreciacion_info_rec.saldo_inicial := ln_inicial_ytd; **/
                                    if '1235' = ls_cuenta then 
                                     lt_depreciacion_info_rec.saldo_inicial := (-1)*(ln_deprn_saldo_inicial +ln_dif_prop_vs_arrend);
                                     ln_deprn_subtotal_inicial   := ln_deprn_subtotal_inicial+(ln_deprn_saldo_inicial +ln_dif_prop_vs_arrend); 
                                    else
                                     lt_depreciacion_info_rec.saldo_inicial := ln_deprn_saldo_inicial;
                                     ln_deprn_subtotal_inicial   := ln_deprn_subtotal_inicial+(ln_deprn_saldo_inicial); 
                                    end if;
                                    
                                    
                                    lt_depreciacion_info_rec.ret_moi_sin_ingr :=0;
                                    /**ln_depre := ln_debito - ln_credito;**/
                                     ln_depre := ln_depren_ejercicio;
                                    lt_depreciacion_info_rec.depn_del_ejercicio := ln_depre;
                                    /** lt_depreciacion_info_rec.suma := ln_suma_ptd; **/
                                    lt_depreciacion_info_rec.suma  := ln_depre; 
                                    
                                    ln_sub_deprn_ejerc := ln_sub_deprn_ejerc +ln_depre; 
                                    
                                    /**lt_depreciacion_info_rec.saldo_final := ln_final_ytd;**/
                                    if '1235' = ls_cuenta then 
                                     lt_depreciacion_info_rec.saldo_final :=(-1)*( ln_deprn_saldo_final +ln_dif_prop_vs_arrend);
                                     ln_deprn_subtotal_final     := ln_deprn_subtotal_final+(ln_deprn_saldo_final +ln_dif_prop_vs_arrend);
                                    else
                                     lt_depreciacion_info_rec.saldo_final := ln_deprn_saldo_final;
                                     ln_deprn_subtotal_final     := ln_deprn_subtotal_final+(ln_deprn_saldo_final);
                                    end if;
                                    
                                    
                                    
    
                                    
                                    /*** codigo para la parte de baja - DPN sin ingresos ***/
                                    APPS.XXGAM_SAF_UTIL_V1_PKG.get_deprn_info ( PSO_ERRMSG            => PSO_ERRMSG 
                                                 , PSO_ERRCOD           => PSO_ERRCOD
                                                 , PSI_OPERATING_UNIT   => PSI_OPERATING_UNIT
                                                 , PSI_PERIOD_NAME      => psi_periodo
                                                 , psi_cuenta           => ls_cuenta 
                                                 , psi_sub_cuenta        => ls_subcuenta
                                                 , PTI_CATEGORY_TBL     => LT_CATEGORY_TBL
                                                 , pno_deprn_x_venta    => ln_deprn_x_venta
                                                 , pno_deprn_scrap      => ln_deprn_scrap
                                                 , pno_deprn_x_venta_usd    => ln_deprn_x_venta_usd
                                                 , pno_deprn_scrap_usd      => ln_deprn_sin_ingreso_usd
                                                 );
                                    
                                    /*****************************************************/
                                    if psi_divisa = 'GAM_MXN' then
                                        lt_depreciacion_info_rec.ret_dpn_sin_ingr := ln_deprn_scrap;
                                        lt_depreciacion_info_rec.ret_dpn_x_venta := ln_deprn_x_venta;  
                                    else
                                        lt_depreciacion_info_rec.ret_dpn_sin_ingr := ln_deprn_x_venta_usd;
                                        lt_depreciacion_info_rec.ret_dpn_x_venta := ln_deprn_sin_ingreso_usd;
                                    end if;    
                                    
                                    lt_depreciacion_info_rec.suma := nvl(lt_depreciacion_info_rec.ret_dpn_sin_ingr,0) +  nvl(lt_depreciacion_info_rec.ret_dpn_x_venta,0) +nvl(lt_depreciacion_info_rec.depn_del_ejercicio,0)+nvl(null,0); 
                                    
                                    ln_sub_deprn_sin_ingreso_dpn := nvl(ln_sub_deprn_sin_ingreso_dpn,0) + nvl(lt_depreciacion_info_rec.ret_dpn_sin_ingr,0);
                                    ln_sub_deprn_x_venta_dpn := nvl(ln_sub_deprn_x_venta_dpn,0) + nvl(lt_depreciacion_info_rec.ret_dpn_x_venta,0);
                                    
                                    lt_depreciacion_tbl(get_descr_info%ROWCOUNT) := lt_depreciacion_info_rec; 
                                    ln_sub_adicion_dpn :=0;
                                    ln_sub_disinv_dpn :=0;
                                    ln_sub_transf_dpn := 0;
                                    
                                    
                                    lt_depreciacion_tbl(get_descr_info%ROWCOUNT) := lt_depreciacion_info_rec; 
                                    ln_sub_adicion_dpn :=0;
                                    ln_sub_disinv_dpn :=0;
                                    ln_sub_depeje_dpn :=ln_sub_depeje_dpn+ln_depre;
   
                                else
                                 null; 
                                end if; 
                                close get_saldo_info; 
                                
                    END LOOP;
                 CLOSE get_descr_info;
                 
                 
        
        if ls_agrupado = 'INVERSION' then
        lt_subtotal_inversion_info_rec.agrupado := ls_agrupado; 
        lt_subtotal_inversion_info_rec.saldo_inicial := ln_sub_val_orig_mxn;  /**ln_subtotal_inicial;**/ 
        /** lt_subtotal_inversion_info_rec.saldo_final := ln_sub_val_orig_mxn; *ln_subtotal_final*/
        lt_subtotal_inversion_info_rec.ad_altas := ln_sub_adicion_inv;
        lt_subtotal_inversion_info_rec.ad_dism_inversa := ln_sub_disinv_inv;
        lt_subtotal_inversion_info_rec.ad_transferencia := ln_sub_transf_inv;
        lt_subtotal_inversion_info_rec.ret_moi_sin_ingr := ln_sub_baja_sin_ingreso_inv;
        lt_subtotal_inversion_info_rec.ret_moi_x_venta := ln_sub_baja_x_venta_inv; 
        lt_subtotal_inversion_info_rec.depn_del_ejercicio := ln_sub_depeje_inv;
        
        lt_subtotal_inversion_info_rec.suma :=  lt_subtotal_inversion_info_rec.ad_altas +  lt_subtotal_inversion_info_rec.ad_dism_inversa;
        lt_subtotal_inversion_info_rec.suma := lt_subtotal_inversion_info_rec.suma + lt_subtotal_inversion_info_rec.ad_transferencia +lt_subtotal_inversion_info_rec.ret_moi_sin_ingr+lt_subtotal_inversion_info_rec.ret_moi_x_venta; 
        
        lt_subtotal_inversion_info_rec.saldo_final := lt_subtotal_inversion_info_rec.saldo_inicial +  lt_subtotal_inversion_info_rec.suma; 
        
        ltt_inversion_set_rec.et_inversion_tbl := lt_inversion_tbl;
        ltt_inversion_set_rec.et_subtotal_agrupado_rec := lt_subtotal_inversion_info_rec;
        end if;
        
        if ls_agrupado = 'MF' then
            lt_subtotal_mf_info_rec.agrupado := ls_agrupado; 
            lt_subtotal_mf_info_rec.saldo_inicial := ln_subtotal_inicial; 
            lt_subtotal_mf_info_rec.saldo_final := ln_subtotal_final; 
            lt_subtotal_mf_info_rec.ad_altas := ln_sub_adicion_mf;
            lt_subtotal_mf_info_rec.ad_dism_inversa := ln_sub_disinv_mf;
            lt_subtotal_mf_info_rec.ad_transferencia := 0;              ---Se igualo a cero para la suma
            lt_subtotal_mf_info_rec.ret_moi_sin_ingr := ln_sub_baja_sin_ingreso_mf;
            lt_subtotal_mf_info_rec.depn_del_ejercicio := ln_sub_depeje_mf;
            lt_subtotal_mf_info_rec.suma := ln_subtotal_ptd;
            
            ltt_moneda_funcional_set_rec.et_moneda_funcional_tbl := lt_moneda_funcional_tbl;
            ltt_moneda_funcional_set_rec.et_subtotal_agrupado_rec :=lt_subtotal_mf_info_rec;
        end if;

        if ls_agrupado = 'DPN' then
        lt_subtotal_dpn_info_rec.agrupado := ls_agrupado; 
        lt_subtotal_dpn_info_rec.saldo_inicial :=(-1)*ln_deprn_subtotal_inicial; /** ln_subtotal_inicial; **/
        lt_subtotal_dpn_info_rec.saldo_final := (-1)*ln_deprn_subtotal_final;     /** ln_subtotal_final; **/ 
        lt_subtotal_dpn_info_rec.ad_altas := ln_sub_adicion_dpn;
        lt_subtotal_dpn_info_rec.ad_dism_inversa := ln_sub_disinv_dpn;
        lt_subtotal_dpn_info_rec.ad_transferencia := 0;                 ---Se igualo a cero para la suma
        
        lt_subtotal_dpn_info_rec.ret_moi_sin_ingr := 0;
        lt_subtotal_dpn_info_rec.ret_moi_x_venta  := 0; 
        
        lt_subtotal_dpn_info_rec.ret_dpn_sin_ingr := ln_sub_deprn_sin_ingreso_dpn;
        lt_subtotal_dpn_info_rec.ret_dpn_x_venta  := ln_sub_deprn_x_venta_dpn; 
        
        lt_subtotal_dpn_info_rec.depn_del_ejercicio := ln_sub_depeje_dpn;
        /** lt_subtotal_dpn_info_rec.suma := ln_subtotal_ptd; **/
        lt_subtotal_dpn_info_rec.suma := nvl(lt_subtotal_dpn_info_rec.ret_dpn_sin_ingr,0) + nvl(lt_subtotal_dpn_info_rec.ret_dpn_x_venta,0) + nvl(lt_subtotal_dpn_info_rec.depn_del_ejercicio,0) +nvl(null,0); 
        ltt_depreciacion_set_rec.et_depreciacion_tbl := lt_depreciacion_tbl;
        ltt_depreciacion_set_rec.et_subtotal_agrupado_rec := lt_subtotal_dpn_info_rec;
        end if;

        ln_total_inicial := ln_total_inicial + ln_subtotal_inicial; 
        ln_total_ptd := ln_total_ptd + ln_subtotal_ptd;
        ln_total_final := ln_total_final + ln_subtotal_final; 
        ln_vnl_adicion :=ln_vnl_adicion + ln_sub_adicion_inv + ln_sub_adicion_mf + ln_sub_adicion_dpn;
        ln_vnl_disinv :=ln_vnl_disinv + ln_sub_disinv_inv + ln_sub_disinv_mf + ln_sub_disinv_dpn;
        ln_vnl_transfer := ln_sub_transf_inv + ln_sub_transf_mf + ln_sub_transf_dpn; 
        ln_vnl_baja_sin_ingreso := ln_vnl_baja_sin_ingreso + ln_sub_baja_sin_ingreso_inv + ln_sub_baja_sin_ingreso_mf + ln_sub_baja_sin_ingreso_dpn;
        ln_vnl_baja_x_venta:=   ln_vnl_baja_x_venta + ln_sub_baja_x_venta_inv + ln_sub_baja_x_venta_mf + ln_sub_baja_x_venta_dpn; 
        ln_vnl_dpn_sin_ingreso := ln_vnl_dpn_sin_ingreso + ln_sub_dpn_sin_ingreso_inv + ln_sub_dpn_sin_ingreso_mf + ln_sub_dpn_sin_ingreso_dpn;
        ln_vnl_dpn_x_venta:=ln_vnl_dpn_x_venta+ ln_sub_dpn_x_venta_inv + ln_sub_dpn_x_venta_mf + ln_sub_dpn_x_venta_dpn;
        ---ln_vnl_baja_sin_ingreso := ln_vnl_baja_sin_ingreso + ln_sub_baja_sin_ingreso_inv + ln_sub_baja_sin_ingreso_mf + ln_sub_baja_sin_ingreso_dpn;
        
                dbms_output.put_line('ln_vnl_baja_sin_ingreso: '||ln_vnl_baja_sin_ingreso);

       /*********************************************/
       ln_vnl_baja_x_venta := ln_sub_baja_x_venta_inv + ln_sub_baja_x_venta_mf + ln_sub_baja_x_venta_dpn;
        ln_vnl_depeje := ln_vnl_depeje + ln_sub_depeje_inv + ln_sub_depeje_mf + ln_sub_depeje_dpn;
   
   
        end loop;        
         close get_agrupado_info;   
         
        /* lt_subtotal_vnl_info_rec.saldo_inicial := ln_total_inicial;*/
         lt_subtotal_vnl_info_rec.saldo_inicial := lt_subtotal_dpn_info_rec.saldo_inicial + lt_subtotal_mf_info_rec.saldo_inicial + lt_subtotal_inversion_info_rec.saldo_inicial;
         lt_subtotal_vnl_info_rec.suma := lt_subtotal_dpn_info_rec.suma + lt_subtotal_mf_info_rec.suma + lt_subtotal_inversion_info_rec.suma;
         lt_subtotal_vnl_info_rec.saldo_final :=  lt_subtotal_dpn_info_rec.saldo_final + lt_subtotal_mf_info_rec.saldo_final + lt_subtotal_inversion_info_rec.saldo_final;
         lt_subtotal_vnl_info_rec.ad_altas :=ln_vnl_adicion;
         lt_subtotal_vnl_info_rec.ad_dism_inversa :=ln_vnl_disinv;
         lt_subtotal_vnl_info_rec.ad_transferencia := ln_vnl_transfer;
         
         lt_subtotal_vnl_info_rec.ret_moi_sin_ingr := lt_subtotal_inversion_info_rec.ret_moi_sin_ingr + nvl(null,0) +nvl(null,0); 
         lt_subtotal_vnl_info_rec.ret_moi_x_venta := lt_subtotal_inversion_info_rec.ret_moi_x_venta + nvl(null,0) +nvl(null,0);  
         
         lt_subtotal_vnl_info_rec.ret_dpn_sin_ingr := nvl(null,0) +nvl(null,0) + nvl(lt_subtotal_dpn_info_rec.ret_dpn_sin_ingr,0) ; 
         lt_subtotal_vnl_info_rec.ret_dpn_x_venta := nvl(null,0) +nvl(null,0) + nvl(lt_subtotal_dpn_info_rec.ret_dpn_x_venta,0);
         
         lt_subtotal_vnl_info_rec.depn_del_ejercicio :=ln_vnl_depeje;
         
         ltt_by_rubro_rec.et_inversion_set_rec := ltt_inversion_set_rec;
         ltt_by_rubro_rec.et_moneda_funcional_set_rec := ltt_moneda_funcional_set_rec;
         ltt_by_rubro_rec.et_depreciacion_set_rec := ltt_depreciacion_set_rec;
         ltt_by_rubro_rec.et_subtotal_vnl_rec := lt_subtotal_vnl_info_rec; 
    
         for i in lt_inversion_tbl.first .. lt_inversion_tbl.last loop
                lt_inversion_info_rec := lt_inversion_tbl(i); 
         end loop; 
         
         for i in lt_moneda_funcional_tbl.first .. lt_moneda_funcional_tbl.last loop
                lt_moneda_funcional_info_rec := lt_moneda_funcional_tbl(i); 
         end loop; 
         
         for i in lt_depreciacion_tbl.first .. lt_depreciacion_tbl.last loop
                lt_depreciacion_info_rec := lt_depreciacion_tbl(i); 
         end loop; 
    
   
     /** se regresa la variable para el package master **/
      pro_tt_by_rubro_rec := ltt_by_rubro_rec; 
      
      
      /*** comienza la impresion de la tabla ****/
      for i in lt_inversion_tbl.first .. lt_inversion_tbl.last loop
                lt_inversion_info_rec := lt_inversion_tbl(i); 
               dbms_output.put_line(lt_inversion_info_rec.rubro||chr(9)
                ||lt_inversion_info_rec.num_rubro||chr(9)
                ||lt_inversion_info_rec.cuenta||'-'
                ||lt_inversion_info_rec.subcuenta||chr(9)
                ||lt_inversion_info_rec.concepto||chr(9)
                ||lt_inversion_info_rec.saldo_inicial||chr(9)
                ||'ALTAS'||NVL(lt_inversion_info_rec.ad_altas,0)||chr(9)  
                ||NVL(lt_inversion_info_rec.ad_dism_inversa,0)||chr(9)
                ||lt_inversion_info_rec.ad_transferencia||chr(9)
                ||lt_inversion_info_rec.ret_moi_sin_ingr||chr(9)
                ||NVL(lt_inversion_info_rec.suma,0)||chr(9)
                ||NVL(lt_inversion_info_rec.saldo_final,0));
         end loop; 
         
         dbms_output.put_line(lt_subtotal_inversion_info_rec.agrupado||chr(9)
                               ||lt_subtotal_inversion_info_rec.saldo_inicial||chr(9)
                               ||lt_subtotal_inversion_info_rec.ad_altas||chr(9)
                               ||lt_subtotal_inversion_info_rec.ad_dism_inversa||chr(9)
                               ||lt_subtotal_inversion_info_rec.ad_transferencia||chr(9)
                               ||lt_subtotal_inversion_info_rec.ret_moi_sin_ingr||chr(9)
                               ||lt_subtotal_inversion_info_rec.ret_moi_x_venta||chr(9)
                               ||lt_subtotal_inversion_info_rec.suma||chr(9)
                               ||lt_subtotal_inversion_info_rec.saldo_final);
         dbms_output.put_line(' ');
         for i in lt_moneda_funcional_tbl.first .. lt_moneda_funcional_tbl.last loop
                lt_moneda_funcional_info_rec := lt_moneda_funcional_tbl(i); 
                dbms_output.put_line(lt_moneda_funcional_info_rec.rubro||chr(9)
                ||lt_moneda_funcional_info_rec.num_rubro||chr(9)
                ||lt_moneda_funcional_info_rec.cuenta||'-'
                ||lt_moneda_funcional_info_rec.subcuenta||chr(9)
                ||lt_moneda_funcional_info_rec.concepto||chr(9)
                ||lt_moneda_funcional_info_rec.saldo_inicial||chr(9)
                ||NVL(lt_moneda_funcional_info_rec.ad_altas,0)||chr(9)  
                ||NVL(lt_moneda_funcional_info_rec.ad_dism_inversa,0)||chr(9)
                ||lt_moneda_funcional_info_rec.ad_transferencia||chr(9)
                ||lt_moneda_funcional_info_rec.ret_moi_sin_ingr||chr(9)
                ||NVL(lt_moneda_funcional_info_rec.suma,0)||chr(9)
                ||NVL(lt_moneda_funcional_info_rec.saldo_final,0)||chr(9));
         end loop; 
          dbms_output.put_line(lt_subtotal_mf_info_rec.agrupado||chr(9)
                               ||lt_subtotal_mf_info_rec.saldo_inicial||chr(9)
                               ||lt_subtotal_mf_info_rec.ad_altas||chr(9)
                               ||lt_subtotal_mf_info_rec.ad_dism_inversa||chr(9)
                               ||lt_subtotal_mf_info_rec.ad_transferencia||chr(9)
                               ||lt_subtotal_mf_info_rec.ret_moi_sin_ingr||chr(9)
                               ||lt_subtotal_mf_info_rec.ret_moi_x_venta||chr(9)
                               ||lt_subtotal_mf_info_rec.suma||chr(9)
                               ||lt_subtotal_mf_info_rec.saldo_final||chr(9));
          dbms_output.put_line(' ');
         
         for i in lt_depreciacion_tbl.first .. lt_depreciacion_tbl.last loop
                lt_depreciacion_info_rec := lt_depreciacion_tbl(i); 
                dbms_output.put_line(lt_depreciacion_info_rec.rubro||chr(30)
                ||lt_depreciacion_info_rec.num_rubro||chr(9)
                ||lt_depreciacion_info_rec.cuenta||'-'
                ||lt_depreciacion_info_rec.subcuenta||chr(9)
                ||lt_depreciacion_info_rec.concepto||chr(9)
                ||lt_depreciacion_info_rec.saldo_inicial||chr(9)
                ||NVL(lt_depreciacion_info_rec.ad_altas,0)||chr(9)  
                ||NVL(lt_depreciacion_info_rec.ad_dism_inversa,0)||chr(9)
                ||lt_depreciacion_info_rec.ad_transferencia||chr(9)
                ||lt_depreciacion_info_rec.ret_moi_sin_ingr||chr(9)
                ||lt_depreciacion_info_rec.ret_moi_x_venta||chr(9)
                ||NVL(lt_depreciacion_info_rec.suma,0)||chr(9)
                ||NVL(lt_depreciacion_info_rec.saldo_final,0)||chr(9));
         end loop; 
          dbms_output.put_line('lt_subtotal_dpn_info_rec.agrupado:'||lt_subtotal_dpn_info_rec.agrupado||chr(9)
                                ||lt_subtotal_dpn_info_rec.saldo_inicial||chr(9)
                                ||lt_subtotal_dpn_info_rec.ad_altas ||chr(9)
                                ||lt_subtotal_dpn_info_rec.ad_dism_inversa||chr(9)
                                ||lt_subtotal_dpn_info_rec.ad_transferencia||chr(9)
                                ||lt_subtotal_dpn_info_rec.ret_moi_sin_ingr ||chr(9)
                                ||lt_subtotal_dpn_info_rec.ret_moi_x_venta ||chr(9)
                                ||'----'||lt_subtotal_dpn_info_rec.ret_dpn_sin_ingr||'----'||chr(9)
                                ||lt_subtotal_dpn_info_rec.ret_dpn_x_venta||chr(9)
                                ||lt_subtotal_dpn_info_rec.suma||chr(9)
                                ||lt_subtotal_dpn_info_rec.saldo_final);
          dbms_output.put_line(' ');
          dbms_output.put_line(lt_subtotal_vnl_info_rec.saldo_inicial||chr(9)
                          ||lt_subtotal_vnl_info_rec.ad_altas||chr(9)
                          ||lt_subtotal_vnl_info_rec.ad_dism_inversa||chr(9)
                          ||lt_subtotal_vnl_info_rec.ad_transferencia||chr(9)
                          ||lt_subtotal_vnl_info_rec.ret_moi_sin_ingr||chr(9)
                          ||lt_subtotal_vnl_info_rec.ret_moi_x_venta||chr(9)
                          ||lt_subtotal_vnl_info_rec.depn_del_ejercicio||chr(9)
                          ||lt_subtotal_vnl_info_rec.suma||chr(9)
                          ||lt_subtotal_vnl_info_rec.saldo_final);


     fnd_file.put_line(fnd_file.log,'Finaliza Ejecuta RUBRO6');   
     fnd_file.put_line(fnd_file.log,'******************************************');  
    
      EXCEPTION WHEN NO_DATA_FOUND THEN
         pso_errmsg := 'Exception NoDataFound';
         pso_errcod := '2';
         P_LOG ('PROCEDURE:' || 'MAIN');
      WHEN OTHERS THEN
         pso_errmsg := 'Exception others: ' || SQLERRM || ',' || SQLCODE;
         pso_errcod := '2';
         P_LOG ('PROCEDURE:' || 'MAIN');
         P_LOG ('Excepcion Programa:' || pso_errmsg);
         
     END execute_rubro; 
   
END XXGAM_SAF_RUBRO6_PKG; 
/

