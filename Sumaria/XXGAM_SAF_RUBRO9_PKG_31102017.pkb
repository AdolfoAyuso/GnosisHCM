CREATE OR REPLACE package body APPS.XXGAM_SAF_RUBRO9_PKG as


PROCEDURE R9(x_errbuf OUT VARCHAR2, x_retcode OUT NUMBER, p_periodo IN VARCHAR2) IS

CURSOR cur_clasf IS
SELECT DISTINCT AGRUPADO 
FROM XXGAM_SAF_SETUP
WHERE ID_RUBRO='9';

ln_suma_saldo_ini   NUMBER := 0;
ln_suma_ptd NUMBER := 0;
ln_suma_ytd NUMBER := 0;
ln_suma_adiciones NUMBER := 0;
ln_suma_disminuciones NUMBER :=0;
lc_agrupado VARCHAR2(100):='A';
ln_vnl_saldo_ini NUMBER := 0;
ln_vnl_ptd NUMBER := 0;
ln_vnl_ytd NUMBER := 0;
ln_vnl_adiciones NUMBER:= 0;
ln_vnl_disminuciones NUMBER:= 0;
ln_vnl_depreciacion NUMBER := 0;
ln_debit NUMBER := 0;
ln_credit NUMBER := 0;
resta NUMBER := 0;
ln_last_ytd NUMBER := 0;

BEGIN

    BEGIN
    hr_util_misc_web.insert_session_row(sysdate);
    END;
   fnd_file.put_line(fnd_file.log,p_periodo);
   fnd_file.put_line(fnd_file.output, '<REPORTE>');
   fnd_file.put_line(fnd_file.output, '<P_PERIODO>' || p_periodo || '</P_PERIODO>');
   fnd_file.put_line(fnd_file.output, '<ENCABEZADO>'||'SUMARIA RUBRO 9'||'</ENCABEZADO>');
   FOR cur_max
   IN cur_clasf
   LOOP 
        fnd_file.put_line(fnd_file.output, '<CLASIFICACION>');
        
        DECLARE
        
            CURSOR cur_per_asg is
                SELECT SAF.RUBRO RUBRO,
                SAF.ID_RUBRO NO_RUBRO,
                SAF.CUENTA || '-' || SAF.SUBCUENTA CUENTA,
                SAF.DESCRIPCION_CUENTA || '  ' || SAF.DESCRIPCION_SUBCUENTA CONCEPTO,
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
                  + (NVL (BA.period_net_dr, 0) - NVL (BA.period_net_cr, 0)))) SALDO_FINAL,
                LT.PERIOD_NAME PERIOD,
                SAF.AGRUPADO AGRUPADO,
                CC.CODE_COMBINATION_ID CODE_COMBINATION  
                FROM GL_LEDGERS LG, 
                GL_CODE_COMBINATIONS CC,
                GL_PERIODS LT,
                GL_BALANCES BA,
                GL_LEDGER_RELATIONSHIPS LR,
                XXGAM_SAF_SETUP SAF
                WHERE 1=1
                AND LG.CHART_OF_ACCOUNTS_ID = CC.CHART_OF_ACCOUNTS_ID
                AND LG.NAME='GAM_MXN'
                AND LG.PERIOD_SET_NAME=LT.PERIOD_SET_NAME
                AND BA.CODE_COMBINATION_ID=CC.CODE_COMBINATION_ID
                AND BA.PERIOD_NAME=LT.PERIOD_NAME
                AND BA.CURRENCY_CODE=LG.CURRENCY_CODE
                AND BA.LEDGER_ID=LG.LEDGER_ID
                AND LR.SOURCE_LEDGER_ID=LR.TARGET_LEDGER_ID
                AND LG.LEDGER_ID=LR.TARGET_LEDGER_ID
                AND LR.TARGET_CURRENCY_CODE=LG.CURRENCY_CODE
                AND SEGMENT1='02'
                AND SEGMENT2='00'
                AND SEGMENT3='000000'
                AND SEGMENT4='0000'
                AND SEGMENT5=SAF.CUENTA
                AND SEGMENT6=SAF.SUBCUENTA 
                AND SEGMENT7='0000'
                AND SEGMENT8='00'
                AND LT.PERIOD_NAME=p_periodo
                AND SAF.ID_RUBRO='9'
                AND BA.ACTUAL_FLAG='A'
                AND SAF.AGRUPADO=cur_max.AGRUPADO
                ORDER BY SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5, SEGMENT6, SEGMENT7, SEGMENT8;
                
                BEGIN
                
                FOR cur_aux
                IN cur_per_asg
                LOOP
                        fnd_file.put_line(fnd_file.output, '<CUENTA>');
                        fnd_file.put_line(fnd_file.output, '<RUBRO>'||cur_aux.RUBRO||'</RUBRO>');
                        fnd_file.put_line(fnd_file.output, '<NO_RUBRO>'||cur_aux.NO_RUBRO||'</NO_RUBRO>');
                        fnd_file.put_line(fnd_file.output, '<ACCOUNT>'||cur_aux.CUENTA||'</ACCOUNT>');
                        fnd_file.put_line(fnd_file.output, '<CONCEPTO>'||cur_aux.CONCEPTO||'</CONCEPTO>');
                        ln_last_ytd := APPS.XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(SUBSTR(cur_aux.CUENTA,1,4), SUBSTR(cur_aux.CUENTA,6,10), p_periodo, 'GAM_MXN', '02');
                        fnd_file.put_line(fnd_file.output, '<SALDO_INICIAL>'||ln_last_ytd||'</SALDO_INICIAL>');
                        IF cur_aux.AGRUPADO = 'DPN' THEN 
                            ln_debit:=XXGAM_SAF_UTIL_V1_PKG.ADDITION(cur_aux.CODE_COMBINATION, p_periodo,'GAM_MXN');
                            ln_credit:=XXGAM_SAF_UTIL_V1_PKG.REDUCTION(cur_aux.CODE_COMBINATION, p_periodo,'GAM_MXN');
                            resta:=ln_debit - ln_credit;
                            fnd_file.put_line(fnd_file.output, '<DEPRECIACION>'|| resta ||'</DEPRECIACION>');
                            ln_vnl_depreciacion := ln_vnl_depreciacion + (ln_debit - ln_credit);
                            ln_debit:=0;
                            ln_credit:=0;
                            resta:=0;
                        ELSE 
                            ln_debit:=XXGAM_SAF_UTIL_V1_PKG.ADDITION(cur_aux.CODE_COMBINATION, p_periodo,'GAM_MXN');
                            fnd_file.put_line(fnd_file.output, '<ADICIONES>'|| ln_debit ||'</ADICIONES>');
                            ln_suma_adiciones := ln_suma_adiciones + ln_debit;
                            ln_vnl_adiciones := ln_vnl_adiciones + ln_debit;
                            ln_debit:=0;
                            ln_credit:=XXGAM_SAF_UTIL_V1_PKG.REDUCTION(cur_aux.CODE_COMBINATION, p_periodo,'GAM_MXN');
                            fnd_file.put_line(fnd_file.output, '<DISMINUCIONES>'|| ln_credit ||'</DISMINUCIONES>');
                            ln_suma_disminuciones := ln_suma_disminuciones + ln_credit;
                            ln_vnl_disminuciones := ln_vnl_disminuciones + ln_credit;
                            ln_credit:=0;
                        END IF;
                        fnd_file.put_line(fnd_file.output, '<SUMA>'||cur_aux.PTD||'</SUMA>');
                        fnd_file.put_line(fnd_file.output, '<SALDO_FINAL>'||cur_aux.SALDO_FINAL||'</SALDO_FINAL>');
                        fnd_file.put_line(fnd_file.output, '<AGRUPADO>'||cur_aux.AGRUPADO||'</AGRUPADO>');
                        fnd_file.put_line(fnd_file.output, '</CUENTA>');
                        ln_suma_saldo_ini := ln_suma_saldo_ini + ln_last_ytd;
                        ln_suma_ptd := ln_suma_ptd + cur_aux.PTD;
                        ln_suma_ytd := ln_suma_ytd + cur_aux.SALDO_FINAL;
                        lc_agrupado := cur_aux.AGRUPADO;
                        ln_vnl_saldo_ini := ln_vnl_saldo_ini + ln_last_ytd;
                        ln_vnl_ptd := ln_vnl_ptd + cur_aux.PTD;
                        ln_vnl_ytd := ln_vnl_ytd + cur_aux.SALDO_FINAL;
                        ln_last_ytd := 0;
                END LOOP;
                END;
                
        fnd_file.put_line(fnd_file.output, '<AGRUPADO_2>' || lc_agrupado || '</AGRUPADO_2>');
        lc_agrupado:='A';
        fnd_file.put_line(fnd_file.output, '<SALDO_INICIAL_TOTAL>' || ln_suma_saldo_ini || '</SALDO_INICIAL_TOTAL>');
        ln_suma_saldo_ini:=0;
        fnd_file.put_line(fnd_file.output, '<SUMA_TOTAL>' || ln_suma_ptd || '</SUMA_TOTAL>');
        ln_suma_ptd:=0;
        fnd_file.put_line(fnd_file.output, '<SALDO_FINAL_TOTAL>' || ln_suma_ytd || '</SALDO_FINAL_TOTAL>');
        ln_suma_ytd:=0;
        fnd_file.put_line(fnd_file.output, '<ADICIONES_TOTAL>' || ln_suma_adiciones || '</ADICIONES_TOTAL>');
        ln_suma_adiciones:=0;
        fnd_file.put_line(fnd_file.output, '<DISMINUCIONES_TOTAL>' || ln_suma_disminuciones || '</DISMINUCIONES_TOTAL>');
        ln_suma_disminuciones:=0;
        fnd_file.put_line(fnd_file.output, '</CLASIFICACION>');
        
        END LOOP;
        
fnd_file.put_line(fnd_file.output, '<VNL_SALDO_INI>' || ln_vnl_saldo_ini || '</VNL_SALDO_INI>');
fnd_file.put_line(fnd_file.output, '<VNL_PTD>' || ln_vnl_ptd || '</VNL_PTD>');
fnd_file.put_line(fnd_file.output, '<VNL_YTD>' || ln_vnl_ytd || '</VNL_YTD>');
fnd_file.put_line(fnd_file.output, '<VNL_ADICIONES>' || ln_vnl_adiciones || '</VNL_ADICIONES>');
fnd_file.put_line(fnd_file.output, '<VNL_DISMINUCIONES>' || ln_vnl_disminuciones || '</VNL_DISMINUCIONES>');
fnd_file.put_line(fnd_file.output, '</REPORTE>');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
               fnd_file.put_line(fnd_file.LOG, 'No hay datos');
    WHEN OTHERS THEN 
               fnd_file.put_line(fnd_file.LOG, sqlerrm);
END;

PROCEDURE EXECUTE_R9(pso_errmsg          out varchar2
                    , pso_errcod          out varchar2
                    , psi_periodo         IN VARCHAR2
                    , psi_operating_unit  IN VARCHAR2
                    , psi_divisa          IN VARCHAR2
                    , pro_tt_by_rubro_rec out xxgam_saf_op_men_pkg.t_by_rubro_rec
                    ) IS

CURSOR cur_clasf IS
SELECT DISTINCT AGRUPADO 
FROM XXGAM_SAF_SETUP
WHERE ID_RUBRO='9';

ln_suma_saldo_ini   NUMBER := 0;
ln_suma_ptd NUMBER := 0;
ln_suma_ytd NUMBER := 0;
ln_suma_adiciones NUMBER := 0;
ln_suma_disminuciones NUMBER :=0;
ln_suma_scrap NUMBER :=0;
ln_suma_venta NUMBER :=0;
ln_suma_deprn_scrap NUMBER :=0;
ln_suma_deprn_venta NUMBER :=0;
lc_agrupado VARCHAR2(100):='A';
ln_vnl_saldo_ini NUMBER := 0;
ln_vnl_ptd NUMBER := 0;
ln_vnl_ytd NUMBER := 0;
ln_vnl_adiciones NUMBER:= 0;
ln_vnl_disminuciones NUMBER:= 0;
ln_vnl_depreciacion NUMBER := 0;
ln_vnl_scrap NUMBER :=0;
ln_vnl_venta NUMBER :=0;
ln_vnl_deprn_scrap NUMBER :=0;
ln_vnl_deprn_venta NUMBER :=0;
ln_debit NUMBER := 0;
ln_credit NUMBER := 0;
resta NUMBER := 0;
ln_last_ytd NUMBER := 0;

lt_by_rubro_rec                xxgam_saf_op_men_pkg.t_by_rubro_rec; 
let_inversion_tbl            xxgam_saf_op_men_pkg.t_inversion_tbl; 
let_moneda_funcional_tbl     xxgam_saf_op_men_pkg.t_moneda_funcional_tbl;
let_depreciacion_tbl         xxgam_saf_op_men_pkg.t_depreciacion_tbl;
let_subtotal_vnl_rec         xxgam_saf_op_men_pkg.t_subtotal_vnl_rec; 

ln_op_men_idx                binary_integer := 0; 
ln_inversion_idx             binary_integer := 0;
ln_moneda_funcional_idx      binary_integer := 0;
ln_dpn_idx                   binary_integer := 0;
  
let_inv_subtotal_rec        xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec;
let_mf_subtotal_rec        xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec;
let_dpn_subtotal_rec        xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec;
 
let_inversion_set_rec           xxgam_saf_op_men_pkg.t_inversion_set_rec;
let_moneda_funcional_set_rec    xxgam_saf_op_men_pkg.t_moneda_funcional_set_rec;
let_depreciacion_set_rec        xxgam_saf_op_men_pkg.t_depreciacion_set_rec; 


 LT_CATEGORY_TBL              XXGAM_SAF_UTIL_V1_PKG.T_CATEGORY_TBL;
 ln_costo_x_venta             number := 0; 
 ln_costo_scrap             number := 0; 
 ln_deprn_x_venta             number := 0; 
 ln_deprn_scrap             number := 0; 
 ln_costo_x_venta_usd             number := 0; 
 ln_costo_scrap_usd             number := 0; 
 ln_deprn_x_venta_usd             number := 0; 
 ln_deprn_scrap_usd             number := 0; 

 divisa_aux                      number := 0;
 
 /********************************************/
 ls_periodo_anterior         varchar2(2000); 
 ls_errmsg                   varchar2(2000); 
 ls_errcod                   varchar2(2000);    
 ln_valor_original_mxn_ini       number :=0; 
 ln_sub_val_orig_mxn_ini         number := 0; 
 ln_valor_original_mxn_fin       number :=0; 
 ln_sub_val_orig_mxn_fin        number := 0; 
 ln_depren_ejercicio         number := 0; 
 
 ln_deprn_saldo_inicial      number := 0; 
 ln_deprn_saldo_final        number := 0; 
 ln_deprn_subtotal_inicial   number := 0; 
 ln_deprn_subtotal_final   number := 0;
    
 /** Ln_diferencia_propios_vs_arrendados **/
 ln_dif_prop_vs_arrend       number := 5460036.68; 
 
 ln_mf_resultados_mxn        number :=0; 
    
    

BEGIN

LT_CATEGORY_TBL(1) :='CONSTRUCCION-MEJORAS-PROPIOS';           /** 1235-16001 **/
LT_CATEGORY_TBL(2) :='CONSTRUCCION-PROPIOS-SIN SUB CATEGORIA'; /** 1233-16001 **/


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


    BEGIN
    hr_util_misc_web.insert_session_row(sysdate);
    END;
    
   fnd_file.put_line(fnd_file.log,psi_periodo);
   fnd_file.put_line(fnd_file.log, 'Comienza a Ejecutarse Operacion Mensual Rubro 9');
   FOR cur_max
   IN cur_clasf
   LOOP 
        
        DECLARE
        
            CURSOR cur_per_asg is
                SELECT XXGAM_SAF_UTIL_V1_PKG.replace_char_esp(SAF.RUBRO) RUBRO,
                SAF.ID_RUBRO NO_RUBRO,
                SAF.CUENTA || '-' || SAF.SUBCUENTA CUENTA,
                SAF.DESCRIPCION_CUENTA || '  ' || SAF.DESCRIPCION_SUBCUENTA CONCEPTO,
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
                  + (NVL (BA.period_net_dr, 0) - NVL (BA.period_net_cr, 0)))) SALDO_FINAL,
                LT.PERIOD_NAME PERIOD,
                SAF.AGRUPADO AGRUPADO,
                SAF.EXCEPTION_ID_RUBRO EXCEPTION_ID,
                CC.CODE_COMBINATION_ID CODE_COMBINATION  
                FROM GL_LEDGERS LG, 
                GL_CODE_COMBINATIONS CC,
                GL_PERIODS LT,
                GL_BALANCES BA,
                GL_LEDGER_RELATIONSHIPS LR,
                XXGAM_SAF_SETUP SAF
                WHERE 1=1
                AND LG.CHART_OF_ACCOUNTS_ID = CC.CHART_OF_ACCOUNTS_ID
                AND LG.NAME=psi_divisa
                --AND LG.NAME = 'GAM_MXN'    
                AND LG.PERIOD_SET_NAME=LT.PERIOD_SET_NAME
                AND BA.CODE_COMBINATION_ID=CC.CODE_COMBINATION_ID
                AND BA.PERIOD_NAME=LT.PERIOD_NAME
                AND BA.CURRENCY_CODE=LG.CURRENCY_CODE
                AND BA.LEDGER_ID=LG.LEDGER_ID
                AND LR.SOURCE_LEDGER_ID=LR.TARGET_LEDGER_ID
                AND LG.LEDGER_ID=LR.TARGET_LEDGER_ID
                AND LR.TARGET_CURRENCY_CODE=LG.CURRENCY_CODE
                AND SEGMENT1=psi_operating_unit /*'02' */
                AND SEGMENT2='00'
                AND SEGMENT3='000000'
                AND SEGMENT4='0000'
                AND SEGMENT5=SAF.CUENTA
                AND SEGMENT6=SAF.SUBCUENTA 
                AND SEGMENT7='0000'
                AND SEGMENT8='00'
                AND LT.PERIOD_NAME=psi_periodo
                AND SAF.ID_RUBRO='9'
                AND BA.ACTUAL_FLAG='A'
                AND SAF.AGRUPADO=cur_max.AGRUPADO
                ORDER BY SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5, SEGMENT6, SEGMENT7, SEGMENT8;
                
                                
                BEGIN
                
                SELECT LEDGER_ID
                INTO DIVISA_AUX
                FROM  GL_LEDGERS
                WHERE NAME=psi_divisa; 
                
                FOR cur_aux
                IN cur_per_asg
                LOOP
                    IF cur_aux.AGRUPADO = 'INVERSION' THEN
                        ln_inversion_idx := ln_inversion_idx+1;        
                        
                        
                        ln_valor_original_mxn_ini := 0; 
                         if psi_divisa = 'GAM_MXN' then
                         APPS.XXGAM_SAF_UTIL_V1_PKG.GET_SDO_VALOR_ORIGINAL_MXN ( PSO_ERRMSG            => ls_errmsg
                                                                            , PSO_ERRCOD              => ls_errcod
                                                                            , PSI_BOOK_CODE           => '02_AMX_CONTABLE'
                                                                            , PSI_PERIOD_NAME         => ls_periodo_anterior
                                                                            , PTI_CATEGORY_TBL        => LT_CATEGORY_TBL
                                                                            , PSI_CUENTA_INV          => SUBSTR(cur_aux.CUENTA,1,4)
                                                                            , PSI_SUBCUENTA_INV       => SUBSTR(cur_aux.CUENTA,6,10)
                                                                            , PNO_VALOR_ORIGINAL_MXN  => ln_valor_original_mxn_ini
                                                                            );
                         APPS.XXGAM_SAF_UTIL_V1_PKG.GET_SDO_VALOR_ORIGINAL_MXN ( PSO_ERRMSG            => ls_errmsg
                                                                            , PSO_ERRCOD              => ls_errcod
                                                                            , PSI_BOOK_CODE           => '02_AMX_CONTABLE'
                                                                            , PSI_PERIOD_NAME         => psi_periodo
                                                                            , PTI_CATEGORY_TBL        => LT_CATEGORY_TBL
                                                                            , PSI_CUENTA_INV          => SUBSTR(cur_aux.CUENTA,1,4)
                                                                            , PSI_SUBCUENTA_INV       => SUBSTR(cur_aux.CUENTA,6,10)
                                                                            , PNO_VALOR_ORIGINAL_MXN  => ln_valor_original_mxn_fin
                                                                            );                                                   
                         end if; 
                        
                        ln_sub_val_orig_mxn_ini := ln_sub_val_orig_mxn_ini + ln_valor_original_mxn_ini; 
                        ln_sub_val_orig_mxn_fin := ln_sub_val_orig_mxn_fin + ln_valor_original_mxn_fin;                                   
                        
                        let_inversion_tbl(ln_inversion_idx).rubro := cur_aux.RUBRO;
                        let_inversion_tbl(ln_inversion_idx).num_rubro := cur_aux.NO_RUBRO;
                        let_inversion_tbl(ln_inversion_idx).cuenta := SUBSTR(cur_aux.CUENTA,1,4);
                        let_inversion_tbl(ln_inversion_idx).subcuenta := SUBSTR(cur_aux.CUENTA,6,10);
                        let_inversion_tbl(ln_inversion_idx).concepto := cur_aux.CONCEPTO;
                        /** Recuperar Monto de la inversion desde Activo Fijo 
                        ln_last_ytd := APPS.XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(SUBSTR(cur_aux.CUENTA,1,4), SUBSTR(cur_aux.CUENTA,6,10), psi_periodo, psi_divisa);
                        let_inversion_tbl(ln_inversion_idx).saldo_inicial := ln_last_ytd;
                         ***/
                        let_inversion_tbl(ln_inversion_idx).saldo_inicial := ln_valor_original_mxn_ini;
                        
                        ln_debit:= 0; /** APPS.XXGAM_SAF_UTIL_V1_PKG.ADDITION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux); **/
                        ln_credit:= 0; /** APPS.XXGAM_SAF_UTIL_V1_PKG.REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux); **/ 
                            --ln_debit := ADDITION(cur_aux.CODE_COMBINATION, psi_periodo);
                            --ln_debit := REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo);                         
                            let_inversion_tbl(ln_inversion_idx).ad_altas := ln_debit - ln_credit;
                            ln_suma_adiciones := ln_suma_adiciones + (ln_debit - ln_credit);
                            ln_vnl_adiciones := ln_vnl_adiciones + (ln_debit - ln_credit);
                            ln_debit:=0;
                            let_inversion_tbl(ln_inversion_idx).ad_dism_inversa := 0;
                            ln_suma_disminuciones := ln_suma_disminuciones + 0;
                            ln_vnl_disminuciones := ln_vnl_disminuciones + 0;
                            ln_credit:=0;
                        let_inversion_tbl(ln_inversion_idx).depn_del_ejercicio := 0;
                        let_inversion_tbl(ln_inversion_idx).suma := cur_aux.PTD;
                        /** let_inversion_tbl(ln_inversion_idx).saldo_final := cur_aux.SALDO_FINAL; **/
                        let_inversion_tbl(ln_inversion_idx).saldo_final := ln_valor_original_mxn_fin; 
                        
                        ln_suma_saldo_ini := ln_suma_saldo_ini + ln_last_ytd;
                        ln_suma_ptd := ln_suma_ptd + cur_aux.PTD;
                        ln_suma_ytd := ln_suma_ytd + cur_aux.SALDO_FINAL;
                        lc_agrupado := cur_aux.AGRUPADO;
                        ln_vnl_saldo_ini := ln_vnl_saldo_ini + ln_last_ytd;
                        ln_vnl_ptd := ln_vnl_ptd + cur_aux.PTD;
                        ln_vnl_ytd := ln_vnl_ytd + cur_aux.SALDO_FINAL;
                        ln_last_ytd := 0;
                        
                        APPS.XXGAM_SAF_UTIL_V1_PKG.GET_RETIREMENT_INFO ( PSO_ERRMSG            => PSO_ERRMSG 
                                                 , PSO_ERRCOD           => PSO_ERRCOD
                                                 , PSI_OPERATING_UNIT   => PSI_OPERATING_UNIT
                                                 , PSI_PERIOD_NAME      => psi_periodo /* PSI_PERIOD_NAME */
                                                 , psi_cuenta           => SUBSTR(cur_aux.CUENTA,1,4)  /** psi_cuenta**/
                                                 , psi_sub_cuenta       => SUBSTR(cur_aux.CUENTA,6,10) /** psi_sub_cuenta **/
                                                 , PTI_CATEGORY_TBL     => LT_CATEGORY_TBL
                                                 , pno_costo_x_venta    => ln_costo_x_venta
                                                 , pno_costo_scrap      => ln_costo_scrap
                                                 , pno_costo_x_venta_usd    => ln_costo_x_venta_usd
                                                 , pno_costo_scrap_usd      => ln_costo_scrap_usd
                                                 );
                        
                        IF PSI_DIVISA='GAM_MXN' THEN
                        let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr := (-1)*ln_costo_scrap;
                        ln_suma_scrap := ln_suma_scrap + let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr;
                        let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta  := (-1)*ln_costo_x_venta;
                        ln_suma_venta := ln_suma_venta + let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta;
                        ln_vnl_scrap := ln_vnl_scrap + ln_costo_scrap;
                        ln_vnl_venta := ln_vnl_venta + ln_costo_x_venta;
                        ln_costo_scrap := 0; 
                        ln_costo_x_venta := 0; 
                        
                        ELSIF PSI_DIVISA='GAM_USD' THEN
                        let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr := (-1)*ln_costo_scrap_usd;
                        ln_suma_scrap := ln_suma_scrap + let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr;
                        let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta  := (-1)*ln_costo_x_venta_usd;
                        ln_suma_venta := ln_suma_venta + let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta;
                        ln_vnl_scrap := ln_vnl_scrap + ln_costo_scrap_usd;
                        ln_vnl_venta := ln_vnl_venta + ln_costo_x_venta_usd;
                        
                        ln_costo_scrap_usd := 0; 
                        ln_costo_x_venta_usd := 0; 
                        
                        END IF;
                        
                    ELSIF cur_aux.AGRUPADO = 'MF' THEN
                        ln_moneda_funcional_idx := ln_moneda_funcional_idx+1;                                          
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).rubro := cur_aux.RUBRO;
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).num_rubro := cur_aux.NO_RUBRO;                        
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).cuenta := SUBSTR(cur_aux.CUENTA,1,4);
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).subcuenta := SUBSTR(cur_aux.CUENTA,6,10);
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).concepto := cur_aux.CONCEPTO;
                        ln_last_ytd := APPS.XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(SUBSTR(cur_aux.CUENTA,1,4), SUBSTR(cur_aux.CUENTA,6,10), psi_periodo, psi_divisa, psi_operating_unit);
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).saldo_inicial := ln_last_ytd;
                            ln_debit:=APPS.XXGAM_SAF_UTIL_V1_PKG.ADDITION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux);
                            ln_credit:=APPS.XXGAM_SAF_UTIL_V1_PKG.REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux);        
                            --ln_debit := ADDITION(cur_aux.CODE_COMBINATION, psi_periodo);
                            --ln_debit := REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo);
                            let_moneda_funcional_tbl(ln_moneda_funcional_idx).ad_altas := ln_debit - ln_credit;
                            ln_suma_adiciones := ln_suma_adiciones + (ln_debit - ln_credit);
                            ln_vnl_adiciones := ln_vnl_adiciones + (ln_debit - ln_credit);
                            ln_debit:=0;
                            let_moneda_funcional_tbl(ln_moneda_funcional_idx).ad_dism_inversa := 0;
                            ln_suma_disminuciones := ln_suma_disminuciones + 0;
                            ln_vnl_disminuciones := ln_vnl_disminuciones + 0;
                            ln_credit:=0;    
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).depn_del_ejercicio := 0;
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).suma := cur_aux.PTD;
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).saldo_final := cur_aux.SALDO_FINAL;
                        ln_suma_saldo_ini := ln_suma_saldo_ini + ln_last_ytd;
                        ln_suma_ptd := ln_suma_ptd + cur_aux.PTD;
                        ln_suma_ytd := ln_suma_ytd + cur_aux.SALDO_FINAL;
                        lc_agrupado := cur_aux.AGRUPADO;
                        ln_vnl_saldo_ini := ln_vnl_saldo_ini + ln_last_ytd;
                        ln_vnl_ptd := ln_vnl_ptd + cur_aux.PTD;
                        ln_vnl_ytd := ln_vnl_ytd + cur_aux.SALDO_FINAL;
                        ln_last_ytd := 0;
                        
                        
                        apps.xxgam_saf_util_v1_pkg.get_mf_resultados_mxn ( pso_errmsg                => LS_ERRMSG
                                                                         , pso_errcod                => LS_ERRCOD
                                                                         , psi_unidad_operativa      => PSI_OPERATING_UNIT
                                                                         , psi_libro                 => '02_AMX_CONTABLE'
                                                                         , psi_periodo               => psi_periodo
                                                                         , psi_categoria_mayor       => 'CONSTRUCCION'
                                                                         ,psi_cuenta_mf              => SUBSTR(cur_aux.CUENTA,1,4)
                                                                         , pno_mf_resultados_mxn     => ln_mf_resultados_mxn
                                                                           );

                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).mf_resultados := ln_mf_resultados_mxn; 
                        let_moneda_funcional_tbl(ln_moneda_funcional_idx).mf_balance := 0; 
                        
                        
                    ELSIF  cur_aux.AGRUPADO = 'DPN' THEN 
                        ln_dpn_idx := ln_dpn_idx+1;                                          
                        let_depreciacion_tbl(ln_dpn_idx).rubro := cur_aux.RUBRO;
                        let_depreciacion_tbl(ln_dpn_idx).num_rubro := cur_aux.NO_RUBRO;
                        let_depreciacion_tbl(ln_dpn_idx).cuenta := SUBSTR(cur_aux.CUENTA,1,4);
                        let_depreciacion_tbl(ln_dpn_idx).subcuenta := SUBSTR(cur_aux.CUENTA,6,10);
                        let_depreciacion_tbl(ln_dpn_idx).concepto := cur_aux.CONCEPTO;
                        ln_last_ytd := APPS.XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(SUBSTR(cur_aux.CUENTA,1,4), SUBSTR(cur_aux.CUENTA,6,10), psi_periodo, psi_divisa, psi_operating_unit);
                          
                        
                        APPS.XXGAM_SAF_UTIL_V1_PKG.GET_DEPRN_INFO ( PSO_ERRMSG            => PSO_ERRMSG 
                                                 , PSO_ERRCOD           => PSO_ERRCOD
                                                 , PSI_OPERATING_UNIT   => PSI_OPERATING_UNIT
                                                 , PSI_PERIOD_NAME      => psi_periodo /* PSI_PERIOD_NAME */
                                                 , psi_cuenta           => SUBSTR(cur_aux.CUENTA,1,4)  /** psi_cuenta**/
                                                 , psi_sub_cuenta       => SUBSTR(cur_aux.CUENTA,6,10) /** psi_sub_cuenta **/
                                                 , PTI_CATEGORY_TBL     => LT_CATEGORY_TBL
                                                 , pno_deprn_x_venta    => ln_deprn_x_venta
                                                 , pno_deprn_scrap      => ln_deprn_scrap
                                                 , pno_deprn_x_venta_usd    => ln_deprn_x_venta_usd
                                                 , pno_deprn_scrap_usd      => ln_deprn_scrap_usd
                                                 );
                        IF PSI_DIVISA='GAM_USD' THEN                         
                        let_depreciacion_tbl(ln_dpn_idx).ret_dpn_sin_ingr := ln_deprn_scrap_usd;  
                        ln_suma_deprn_scrap := ln_suma_deprn_scrap + ln_deprn_scrap_usd;     
                        ln_vnl_deprn_scrap := ln_vnl_deprn_scrap + ln_deprn_scrap_usd;
                        let_depreciacion_tbl(ln_dpn_idx).ret_dpn_x_venta := ln_deprn_x_venta_usd;
                        ln_suma_deprn_venta := ln_suma_deprn_venta + ln_deprn_x_venta_usd;    
                        ln_vnl_deprn_venta := ln_vnl_deprn_venta + ln_deprn_x_venta_usd;          
                        
                        ELSIF PSI_DIVISA='GAM_MXN' THEN
                        let_depreciacion_tbl(ln_dpn_idx).ret_dpn_sin_ingr := ln_deprn_scrap;  
                        ln_suma_deprn_scrap := ln_suma_deprn_scrap + ln_deprn_scrap;     
                        ln_vnl_deprn_scrap := ln_vnl_deprn_scrap + ln_deprn_scrap;
                        let_depreciacion_tbl(ln_dpn_idx).ret_dpn_x_venta := ln_deprn_x_venta;
                        ln_suma_deprn_venta := ln_suma_deprn_venta + ln_deprn_x_venta;    
                        ln_vnl_deprn_venta := ln_vnl_deprn_venta + ln_deprn_x_venta;
                        
                        END IF;
                        
                        IF PSI_DIVISA='GAM_MXN' THEN
                         XXGAM_SAF_UTIL_V1_PKG.get_deprn_ejercicio_mxn(pso_errmsg             => ls_errmsg
                                                                      ,pso_errcod            => ls_errcod
                                                                      ,psi_book_code         => '02_AMX_CONTABLE' 
                                                                      ,psi_operating_unit    => PSI_OPERATING_UNIT
                                                                      ,psi_period_name       => psi_periodo
                                                                      ,pti_category_tbl      => LT_CATEGORY_TBL
                                                                      ,psi_cuenta_deprn      => SUBSTR(cur_aux.CUENTA,1,4)
                                                                      ,psi_subcuenta_deprn   => SUBSTR(cur_aux.CUENTA,6,10)
                                                                      ,pno_depren_ejercicio  => ln_depren_ejercicio
                                                                      ); 
                                                                      
                         APPS.XXGAM_SAF_UTIL_V1_PKG.GET_DEPRN_SALDO_MXN ( PSO_ERRMSG            => LS_ERRMSG
                                                                        , PSO_ERRCOD            => LS_ERRCOD
                                                                        , PSI_BOOK_CODE         => '02_AMX_CONTABLE' 
                                                                        , PSI_PERIOD_NAME       => ls_periodo_anterior
                                                                        , PTI_CATEGORY_TBL      => LT_CATEGORY_TBL
                                                                        , PSI_CUENTA_DEPRN      => SUBSTR(cur_aux.CUENTA,1,4)
                                                                        , PSI_SUBCUENTA_DEPRN   => SUBSTR(cur_aux.CUENTA,6,10)
                                                                        , PNO_SALDO_MXN         => ln_deprn_saldo_inicial
                                                                        );                                                  
                                                                                  
                        APPS.XXGAM_SAF_UTIL_V1_PKG.GET_DEPRN_SALDO_MXN ( PSO_ERRMSG            => LS_ERRMSG
                                                                       , PSO_ERRCOD            => LS_ERRCOD
                                                                       , PSI_BOOK_CODE         => '02_AMX_CONTABLE' 
                                                                       , PSI_PERIOD_NAME       => psi_periodo
                                                                       , PTI_CATEGORY_TBL      => LT_CATEGORY_TBL
                                                                       , PSI_CUENTA_DEPRN      => SUBSTR(cur_aux.CUENTA,1,4)
                                                                       , PSI_SUBCUENTA_DEPRN   => SUBSTR(cur_aux.CUENTA,6,10)
                                                                       , PNO_SALDO_MXN         => ln_deprn_saldo_final
                                                                        );   
                                                                     
                        END IF; 
                        
                        ln_debit:=APPS.XXGAM_SAF_UTIL_V1_PKG.ADDITION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux);
                        ln_credit:=APPS.XXGAM_SAF_UTIL_V1_PKG.REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux);        
                        --ln_debit := ADDITION(cur_aux.CODE_COMBINATION, psi_periodo);
                        --ln_debit := REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo);
                        resta:=ln_debit - ln_credit;
                       /** let_depreciacion_tbl(ln_dpn_idx).depn_del_ejercicio := resta; **/
                        let_depreciacion_tbl(ln_dpn_idx).depn_del_ejercicio := ln_depren_ejercicio; 
                       
                        let_depreciacion_tbl(ln_dpn_idx).ad_altas := 0;
                        let_depreciacion_tbl(ln_dpn_idx).ad_dism_inversa := 0;
                       /** ln_vnl_depreciacion := ln_vnl_depreciacion + (ln_debit - ln_credit); **/
                        ln_vnl_depreciacion := ln_vnl_depreciacion + ln_depren_ejercicio; 
                        ln_debit:=0;
                        ln_credit:=0;
                        resta:=0;
                               /** let_depreciacion_tbl(ln_dpn_idx).saldo_inicial := ln_last_ytd;  **/
                        if '1235' = SUBSTR(cur_aux.CUENTA,1,4) then 
                        let_depreciacion_tbl(ln_dpn_idx).saldo_inicial := (-1)*(ln_deprn_saldo_inicial -ln_dif_prop_vs_arrend);
                        ln_deprn_subtotal_inicial   := ln_deprn_subtotal_inicial-(ln_deprn_saldo_inicial -ln_dif_prop_vs_arrend);/*el original tenia +*/
                        else 
                        let_depreciacion_tbl(ln_dpn_idx).saldo_inicial :=(-1)* ln_deprn_saldo_inicial;
                        ln_deprn_subtotal_inicial   := ln_deprn_subtotal_inicial-(ln_deprn_saldo_inicial);
                        end if; 
                        
                        ln_suma_saldo_ini := ln_suma_saldo_ini + ln_last_ytd;
                        ln_suma_ptd := ln_suma_ptd + cur_aux.PTD;
                        /** let_depreciacion_tbl(ln_dpn_idx).saldo_final := cur_aux.SALDO_FINAL; **/
                       
                         if '1235' = SUBSTR(cur_aux.CUENTA,1,4) then
                         let_depreciacion_tbl(ln_dpn_idx).saldo_final :=(-1)*( ln_deprn_saldo_final - ln_dif_prop_vs_arrend);
                         ln_deprn_subtotal_final     := ln_deprn_subtotal_final-(ln_deprn_saldo_final - ln_dif_prop_vs_arrend);
                         else 
                         let_depreciacion_tbl(ln_dpn_idx).saldo_final := (-1)*ln_deprn_saldo_final;
                         ln_deprn_subtotal_final     := ln_deprn_subtotal_final-(ln_deprn_saldo_final);
                         end if; 
                         let_depreciacion_tbl(ln_dpn_idx).suma :=  let_depreciacion_tbl(ln_dpn_idx).ad_altas  +  let_depreciacion_tbl(ln_dpn_idx).ad_dism_inversa +  let_depreciacion_tbl(ln_dpn_idx).ret_dpn_sin_ingr 
                        + let_depreciacion_tbl(ln_dpn_idx).ret_dpn_x_venta + let_depreciacion_tbl(ln_dpn_idx).depn_del_ejercicio;  /*cur_aux.PTD;*/
                
                
                
                        lc_agrupado := cur_aux.AGRUPADO;
                        ln_vnl_saldo_ini := ln_vnl_saldo_ini + ln_last_ytd;
                        ln_vnl_ptd := ln_vnl_ptd + cur_aux.PTD;
                        ln_vnl_ytd := ln_vnl_ytd + cur_aux.SALDO_FINAL;
                        ln_last_ytd := 0;
                
                        let_dpn_subtotal_rec.suma :=let_dpn_subtotal_rec.suma +    let_depreciacion_tbl(ln_dpn_idx).suma;
                        
                        
                    END IF;                       
                END LOOP;
                END;
        
        IF lc_agrupado='INVERSION' THEN
            let_inv_subtotal_rec.agrupado := lc_agrupado;       
            lc_agrupado:='A';
            let_inv_subtotal_rec.saldo_inicial := ln_sub_val_orig_mxn_ini; /**ln_suma_saldo_ini;**/
            ln_suma_saldo_ini:=0;
            let_inv_subtotal_rec.suma := ln_suma_ptd;
            ln_suma_ptd:=0;
            let_inv_subtotal_rec.saldo_final :=  ln_sub_val_orig_mxn_fin; /**ln_suma_ytd;**/
            ln_suma_ytd:=0;
            let_inv_subtotal_rec.ad_altas := ln_suma_adiciones;
            ln_suma_adiciones:=0;
            let_inv_subtotal_rec.ad_dism_inversa := ln_suma_disminuciones;
            ln_suma_disminuciones:=0;
            let_inv_subtotal_rec.ret_moi_sin_ingr:= ln_suma_scrap;
            ln_suma_scrap := 0;
            let_inv_subtotal_rec.ret_moi_x_venta := ln_suma_venta;
            ln_suma_venta:=0;
            let_inv_subtotal_rec.depn_del_ejercicio:=0;
            let_inversion_set_rec.et_inversion_tbl:=let_inversion_tbl;
            let_inversion_set_rec.et_subtotal_agrupado_rec:=let_inv_subtotal_rec;
        ELSIF lc_agrupado='MF' THEN
            let_mf_subtotal_rec.agrupado := lc_agrupado;       
            lc_agrupado:='A';
            let_mf_subtotal_rec.saldo_inicial := ln_suma_saldo_ini;
            ln_suma_saldo_ini:=0;
            let_mf_subtotal_rec.suma := ln_suma_ptd;
            ln_suma_ptd:=0;
            let_mf_subtotal_rec.saldo_final := ln_suma_ytd;
            ln_suma_ytd:=0;
            let_mf_subtotal_rec.ad_altas := ln_suma_adiciones;
            ln_suma_adiciones:=0;
            let_mf_subtotal_rec.ad_dism_inversa := ln_suma_disminuciones;
            ln_suma_disminuciones:=0;
            let_mf_subtotal_rec.depn_del_ejercicio:=0;
            let_moneda_funcional_set_rec.et_moneda_funcional_tbl:=let_moneda_funcional_tbl;
            let_moneda_funcional_set_rec.et_subtotal_agrupado_rec:=let_mf_subtotal_rec;
        ELSIF lc_agrupado='DPN' THEN
            let_dpn_subtotal_rec.agrupado := lc_agrupado;       
            lc_agrupado:='A';
            let_dpn_subtotal_rec.saldo_inicial := ln_deprn_subtotal_inicial; /**ln_suma_saldo_ini; **/
            ln_suma_saldo_ini:=0;
         /*   let_dpn_subtotal_rec.suma := ln_suma_ptd;*/
            ln_suma_ptd:=0;
            let_dpn_subtotal_rec.saldo_final := ln_deprn_subtotal_final;  /**ln_suma_ytd;**/
            ln_suma_ytd:=0;
            let_dpn_subtotal_rec.ad_altas := 0;
            ln_suma_adiciones:=0;
            let_dpn_subtotal_rec.ad_dism_inversa := 0;
            ln_suma_disminuciones:=0;
            let_dpn_subtotal_rec.ret_dpn_sin_ingr:=ln_suma_deprn_scrap;
            ln_suma_deprn_scrap := 0;
            let_dpn_subtotal_rec.ret_dpn_x_venta:=ln_suma_deprn_venta;
            ln_suma_deprn_venta := 0;
            
            let_dpn_subtotal_rec.depn_del_ejercicio:=ln_vnl_depreciacion;
            
            let_depreciacion_set_rec.et_depreciacion_tbl:=let_depreciacion_tbl;
            let_depreciacion_set_rec.et_subtotal_agrupado_rec:=let_dpn_subtotal_rec;         
        END IF;    
        END LOOP;
        
/*let_subtotal_vnl_rec.saldo_inicial := ln_vnl_saldo_ini;*/
let_subtotal_vnl_rec.saldo_inicial :=  let_dpn_subtotal_rec.saldo_inicial +  let_mf_subtotal_rec.saldo_inicial +  let_inv_subtotal_rec.saldo_inicial;
let_subtotal_vnl_rec.suma :=  let_inv_subtotal_rec.suma +  let_mf_subtotal_rec.suma + let_dpn_subtotal_rec.suma ; /*ln_vnl_ptd;*/
let_subtotal_vnl_rec.saldo_final := ln_vnl_ytd;
let_subtotal_vnl_rec.ad_altas := ln_vnl_adiciones;
let_subtotal_vnl_rec.ad_dism_inversa := ln_vnl_disminuciones;
let_subtotal_vnl_rec.ret_moi_sin_ingr := ln_vnl_scrap;
let_subtotal_vnl_rec.ret_moi_x_venta := ln_vnl_venta;
let_subtotal_vnl_rec.ret_dpn_sin_ingr := ln_vnl_deprn_scrap;
let_subtotal_vnl_rec.ret_dpn_x_venta := ln_vnl_deprn_venta;
let_subtotal_vnl_rec.depn_del_ejercicio := ln_vnl_depreciacion;

lt_by_rubro_rec.et_inversion_set_rec := let_inversion_set_rec;
lt_by_rubro_rec.et_moneda_funcional_set_rec := let_moneda_funcional_set_rec;
lt_by_rubro_rec.et_depreciacion_set_rec := let_depreciacion_set_rec;
lt_by_rubro_rec.et_subtotal_vnl_rec := let_subtotal_vnl_rec;

pro_tt_by_rubro_rec := lt_by_rubro_rec;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
               fnd_file.put_line(fnd_file.LOG, 'No hay datos');
    WHEN OTHERS THEN 
               fnd_file.put_line(fnd_file.LOG, sqlerrm);


END;


PROCEDURE GET_MF_BALANCE(pso_errmsg           out varchar2 
                        ,pso_errcod           out varchar2
                        ,psi_libro            in  varchar2
                        ,psi_periodo          IN VARCHAR2 
                        ) is 

 CURSOR get_asset_info (cur_book_type_code   varchar2
                        ,cur_period_name      varchar2
                        ,cur_categoria_mayor  varchar2
                        ) IS
    select fab.asset_number 
        ,( select fcb.segment1||'-'||fcb.segment2||'-'||fcb.segment3
             from FA_CATEGORIES_B  fcb
            where fcb.category_id = fab.asset_category_id 
          ) category_name
          ,nvl((select  /** fb.original_cost Puede estar sin ajustar **/
                   fb.cost
              from fa_books fb 
                  ,fa_deprn_periods fdp
             where 1=1 
               and fb.book_type_code=fdp.book_type_code
               and fb.book_type_code=  cur_book_type_code /**'02_AMX_CONTABLE'**/
               and fb.asset_id  =  fab.asset_id
               and fdp.period_name = cur_period_name /** 'MAY-17' **/
               and fdp.calendar_period_close_date between fb.date_effective 
               and nvl(fb.date_ineffective,to_date ('31/12/4712','DD/MM/YYYY'))
           ),0) costo_mxn
          ,nvl((select  /** fb.original_cost Puede estar sin ajustar **/
                   fb.cost
              from fa_mc_books fb 
                  ,fa_deprn_periods fdp
             where 1=1 
               and fb.book_type_code=fdp.book_type_code
               and fb.book_type_code=  cur_book_type_code /**'02_AMX_CONTABLE'**/
               and fb.asset_id  =  fab.asset_id
               and fdp.period_name = cur_period_name /** 'MAY-17' **/
               and fdp.calendar_period_close_date between fb.date_effective 
               and nvl(fb.date_ineffective,to_date ('31/12/4712','DD/MM/YYYY'))
           ),0) costo_usd 
          ,nvl((select  fds.deprn_amount
                from  fa_deprn_periods    fdp
                     ,fa.fa_deprn_summary fds
               where  fdp.period_counter = fds.period_counter
                 AND  fdp.book_type_code = fds.book_type_code
                 AND fdp.period_name      = cur_period_name /**'MAY-17'**/
                 AND fds.book_type_code = cur_book_type_code /**'02_AMX_ROTABLES' **/
                 and fds.asset_id = fab.asset_id
                 ),0) ptd_deprn_mxn     
           ,nvl((select  fds.deprn_amount
                from  fa_deprn_periods    fdp
                     ,fa.fa_mc_deprn_summary fds
               where  fdp.period_counter = fds.period_counter
                 AND  fdp.book_type_code = fds.book_type_code
                 AND fdp.period_name      = cur_period_name /**'MAY-17'**/
                 AND fds.book_type_code = cur_book_type_code /**'02_AMX_ROTABLES' **/
                 and fds.asset_id = fab.asset_id
                 ),0) ptd_deprn_usd                 
         ,(select TRANSACTION_TYPE_CODE 
              from  FA_TRANSACTION_HEADERS fth
             where 1=1 
               and fth.asset_id = fab.asset_id
               and BOOK_TYPE_CODE =  cur_book_type_code /** '02_AMX_CONTABLE' **/
               and TRANSACTION_HEADER_ID in (select max(TRANSACTION_HEADER_ID)
                                        from FA_TRANSACTION_HEADERS fth
                                       where fth.asset_id = fab.asset_id
                                         and BOOK_TYPE_CODE =  cur_book_type_code /** '02_AMX_CONTABLE' **/
                                     )
              and TRANSACTION_TYPE_CODE not in ('ADDITION')                       
             ) as ultimo_estado 
           ,nvl((
              select  fds.ytd_deprn
                from  fa_deprn_periods    fdp
                     ,fa.fa_deprn_summary fds
               where  fdp.period_counter = fds.period_counter
                 AND  fdp.book_type_code = fds.book_type_code
                 AND fdp.period_name      =  cur_period_name /**'MAY-17'**/
                 AND fds.book_type_code = cur_book_type_code /**'02_AMX_CONTABLE'**/
                 and fds.asset_id = fab.asset_id
                 ),0) as ytd_deprn     
             ,nvl((
              select  fds.deprn_reserve
                from  fa_deprn_periods    fdp
                     ,fa.fa_deprn_summary fds
               where  fdp.period_counter = fds.period_counter
                 AND  fdp.book_type_code = fds.book_type_code
                 AND fdp.period_name      =  cur_period_name /**'MAY-17'**/
                 AND fds.book_type_code = cur_book_type_code /**'02_AMX_CONTABLE' **/
                 and fds.asset_id = fab.asset_id
                 ),0) as deprn_reserve_mxn    
              ,nvl((
              select  fds.deprn_reserve
                from  fa_deprn_periods    fdp
                     ,fa.fa_mc_deprn_summary fds
               where  fdp.period_counter = fds.period_counter
                 AND  fdp.book_type_code = fds.book_type_code
                 AND fdp.period_name      =  cur_period_name /**'MAY-17'**/
                 AND fds.book_type_code = cur_book_type_code /**'02_AMX_CONTABLE' **/
                 and fds.asset_id = fab.asset_id
                 ),0) as deprn_reserve_usd                             
    from fa_additions_b fab
   where asset_id in (SELECT ASSET_ID
                        FROM FA_BOOKS fb
                           , FA_BOOK_CONTROLS_SEC sec
                       WHERE fb.BOOK_TYPE_CODE LIKE cur_book_type_code /**'02_AMX_CONTABLE'**/
                         AND NVL (DISABLED_FLAG, 'N') = 'N'
                         AND transaction_header_id_out IS NULL
                         AND fb.BOOK_TYPE_CODE = sec.BOOK_TYPE_CODE
                      )
    and fab.asset_category_id in ( select fcb.CATEGORY_ID 
                                 from FA_CATEGORIES_B  fcb
                                where fcb.segment1||'-'||fcb.segment2||'-'||fcb.segment3 = cur_categoria_mayor /** 'MANTENIMIENTO MAYOR' **/
                                  )
                                  ;
 
 CURSOR get_cierre_rate (cur_start_date  date
                        ,cur_end_date    date
                        ) IS
       select CONVERSION_RATE
     from gl_daily_rates
    where 1=1 
      and CONVERSION_TYPE in ( select conversion_type 
                                 from gl_daily_conversion_types
                                where 1=1 
                                  and user_conversion_type = 'Cierre'
                                  )
      and from_currency='USD'
      and to_currency='MXN'
      and conversion_date in (select max(CONVERSION_DATE) 
                                from gl_daily_rates
                               where 1=1 
                                 and CONVERSION_TYPE in ( select conversion_type 
                                                            from gl_daily_conversion_types
                                                           where 1=1 
                                                             and user_conversion_type = 'Cierre'
                                                         )
                                 and from_currency='USD'
                                 and to_currency='MXN'
                                 and conversion_date between cur_start_date /**to_date ('01/01/2017','DD/MM/YYYY')**/
                                 and cur_end_date /**to_date ('31/01/2017','DD/MM/YYYY')**/
                               );                                  

 asset_info_cmp_rec       get_asset_info%ROWTYPE;  
 asset_info_mta_rec       get_asset_info%ROWTYPE;                    
 asset_info_mtf_rec       get_asset_info%ROWTYPE; 
 asset_info_cps_rec       get_asset_info%ROWTYPE; 
 
 cierre_rate_rec          get_cierre_rate%ROWTYPE;
 
 
 ld_period_start_date     date; 
 ld_period_end_date       date; 
 
 ln_cierre_rate           number:=0; 
 
 
 ln_deprn_reserve_mxn_cmp   number:=0; 
 ln_deprn_reserve_usd_cmp   number:=0;    
 ln_deprn_reserve_mxn_cps   number:=0; 
 ln_deprn_reserve_usd_cps   number:=0;
 ln_deprn_reserve_mxn_mta   number:=0; 
 ln_deprn_reserve_usd_mta   number:=0;                                         
 ln_deprn_reserve_mxn_mtf   number:=0; 
 ln_deprn_reserve_usd_mtf   number:=0;  
 
 ln_vnl_mxn_cmp             number:=0; 
 ln_vnl_usd_cmp             number:=0;   
 ln_vnl_dolarizado_cmp      number:=0; 
 
 ln_vnl_mxn_cps             number:=0; 
 ln_vnl_usd_cps             number:=0;   
 ln_vnl_dolarizado_cps      number:=0; 
 
 ln_vnl_mxn_mta             number:=0; 
 ln_vnl_usd_mta             number:=0;   
 ln_vnl_dolarizado_mta      number:=0; 
 
 ln_vnl_mxn_mtf             number:=0; 
 ln_vnl_usd_mtf             number:=0;   
 ln_vnl_dolarizado_mtf      number:=0; 
 
 ln_prorateo_cmp            number:=0; 
 ln_prorateo_mta            number:=0; 
 ln_prorateo_mtf            number:=0; 
                  
begin 

pso_errmsg := null; 
pso_errcod := '0'; 

 select gp.start_date 
       ,gp.end_date
   into ld_period_start_date 
       ,ld_period_end_date  
   from gl_periods gp
  where gp.period_name = psi_periodo /** 'MAY-17' **/
    and gp.period_set_name = 'GAM';
   
  
  OPEN get_cierre_rate(ld_period_start_date
                       ,ld_period_end_date
                       );
     LOOP
        FETCH get_cierre_rate INTO cierre_rate_rec;
         EXIT WHEN get_cierre_rate%NOTFOUND;
         ln_cierre_rate := cierre_rate_rec.conversion_rate; 
         
      END LOOP;
  CLOSE get_cierre_rate;
  

  OPEN get_asset_info(psi_libro,psi_periodo,'CONSTRUCCION-MEJORAS-PROPIOS');
   LOOP
      FETCH get_asset_info INTO asset_info_cmp_rec;
      EXIT WHEN get_asset_info%NOTFOUND;
      
       if 'FULL RETIREMENT' = asset_info_cmp_rec.ultimo_estado OR 
          'ADJUSTMENT' = asset_info_cmp_rec.ultimo_estado then
          select fds.deprn_reserve
         into ln_deprn_reserve_mxn_cmp
         from fa.fa_deprn_summary fds
        where 1= 1
          AND fds.book_type_code = psi_libro /**'02_AMX_CONTABLE' **/ 
          and fds.asset_id = asset_info_cmp_rec.asset_number
          and fds.deprn_run_date in ( select max(fds_tmp.DEPRN_RUN_DATE) 
                                        from fa.fa_deprn_summary fds_tmp
                                       where fds_tmp.book_type_code = psi_libro /** '02_AMX_CONTABLE' **/
                                         AND fds_tmp.asset_id = asset_info_cmp_rec.asset_number 
                                         and trunc(DEPRN_RUN_DATE) <= ld_period_end_date /**to_date ('31/05/2017','DD/MM/YYYY')**/
                                     )
                                 ;
      
       select fds.deprn_reserve
         into ln_deprn_reserve_usd_cmp
         from fa.fa_mc_deprn_summary fds
        where 1= 1
          AND fds.book_type_code = psi_libro /**'02_AMX_CONTABLE' **/ 
          and fds.asset_id = asset_info_cmp_rec.asset_number
          and fds.deprn_run_date in ( select max(fds_tmp.DEPRN_RUN_DATE) 
                                        from fa.fa_mc_deprn_summary fds_tmp
                                       where fds_tmp.book_type_code = psi_libro /** '02_AMX_CONTABLE' **/
                                         AND fds_tmp.asset_id = asset_info_cmp_rec.asset_number 
                                         and trunc(DEPRN_RUN_DATE) <= ld_period_end_date /**to_date ('31/05/2017','DD/MM/YYYY')**/
                                     )
                                 ;
           ln_vnl_mxn_cmp := ln_vnl_mxn_cmp +(asset_info_cmp_rec.costo_mxn-ln_deprn_reserve_mxn_cmp);  
           ln_vnl_usd_cmp := ln_vnl_usd_cmp +(asset_info_cmp_rec.costo_usd-ln_deprn_reserve_usd_cmp);  
           ln_vnl_dolarizado_cmp := ln_vnl_dolarizado_cmp + ((asset_info_cmp_rec.costo_usd-ln_deprn_reserve_usd_cmp)*ln_cierre_rate);                      
          else 
           ln_vnl_mxn_cmp := ln_vnl_mxn_cmp +(asset_info_cmp_rec.costo_mxn-asset_info_cmp_rec.deprn_reserve_mxn);
           ln_vnl_usd_cmp := ln_vnl_usd_cmp +(asset_info_cmp_rec.costo_usd-asset_info_cmp_rec.deprn_reserve_usd);
           ln_vnl_dolarizado_cmp := ln_vnl_dolarizado_cmp +((asset_info_cmp_rec.costo_usd-asset_info_cmp_rec.deprn_reserve_usd)*ln_cierre_rate);
    
          end if; 
      
   END LOOP;
   CLOSE get_asset_info;
   
    OPEN get_asset_info(psi_libro,psi_periodo,'CONSTRUCCION-PROPIOS-SIN SUB CATEGORIA');
   LOOP
      FETCH get_asset_info INTO asset_info_cps_rec;
      EXIT WHEN get_asset_info%NOTFOUND;
      
       if 'FULL RETIREMENT' = asset_info_cps_rec.ultimo_estado OR 
          'ADJUSTMENT' = asset_info_cps_rec.ultimo_estado then
          select fds.deprn_reserve
         into ln_deprn_reserve_mxn_cps
         from fa.fa_deprn_summary fds
        where 1= 1
          AND fds.book_type_code = psi_libro /**'02_AMX_CONTABLE' **/ 
          and fds.asset_id = asset_info_cps_rec.asset_number
          and fds.deprn_run_date in ( select max(fds_tmp.DEPRN_RUN_DATE) 
                                        from fa.fa_deprn_summary fds_tmp
                                       where fds_tmp.book_type_code = psi_libro /** '02_AMX_CONTABLE' **/
                                         AND fds_tmp.asset_id = asset_info_cps_rec.asset_number 
                                         and trunc(DEPRN_RUN_DATE) <= ld_period_end_date /**to_date ('31/05/2017','DD/MM/YYYY')**/
                                     )
                                 ;
      
       select fds.deprn_reserve
         into ln_deprn_reserve_usd_cps
         from fa.fa_mc_deprn_summary fds
        where 1= 1
          AND fds.book_type_code = psi_libro /**'02_AMX_CONTABLE' **/ 
          and fds.asset_id = asset_info_cps_rec.asset_number
          and fds.deprn_run_date in ( select max(fds_tmp.DEPRN_RUN_DATE) 
                                        from fa.fa_mc_deprn_summary fds_tmp
                                       where fds_tmp.book_type_code = psi_libro /** '02_AMX_CONTABLE' **/
                                         AND fds_tmp.asset_id = asset_info_cps_rec.asset_number 
                                         and trunc(DEPRN_RUN_DATE) <= ld_period_end_date /**to_date ('31/05/2017','DD/MM/YYYY')**/
                                     )
                                 ;
          ln_vnl_mxn_cps := ln_vnl_mxn_cps +(asset_info_cps_rec.costo_mxn-ln_deprn_reserve_mxn_cps);  
          ln_vnl_usd_cps := ln_vnl_usd_cps +(asset_info_cps_rec.costo_usd-ln_deprn_reserve_usd_cps);  
          ln_vnl_dolarizado_cps := ln_vnl_dolarizado_cps + ((asset_info_cps_rec.costo_usd-ln_deprn_reserve_usd_cps)*ln_cierre_rate);
                                  
          else 
           ln_vnl_mxn_cps := ln_vnl_mxn_cps +(asset_info_cps_rec.costo_mxn-asset_info_cps_rec.deprn_reserve_mxn);
           ln_vnl_usd_cps := ln_vnl_usd_cps +(asset_info_cps_rec.costo_usd-asset_info_cps_rec.deprn_reserve_usd);
           ln_vnl_dolarizado_cps := ln_vnl_dolarizado_cps +((asset_info_cps_rec.costo_usd-asset_info_cps_rec.deprn_reserve_usd)*ln_cierre_rate); 
          end if; 
      
   END LOOP;
   CLOSE get_asset_info;
   
   
   
    OPEN get_asset_info(psi_libro,psi_periodo,'MEJORAS PROPIEDADES ARRENDADAS-TERRENOS-AJENOS');
   LOOP
      FETCH get_asset_info INTO asset_info_mta_rec;
      EXIT WHEN get_asset_info%NOTFOUND;
      
       if 'FULL RETIREMENT' = asset_info_mta_rec.ultimo_estado OR 
          'ADJUSTMENT' = asset_info_mta_rec.ultimo_estado then
           select fds.deprn_reserve
         into ln_deprn_reserve_mxn_mta
         from fa.fa_deprn_summary fds
        where 1= 1
          AND fds.book_type_code = psi_libro /**'02_AMX_CONTABLE' **/ 
          and fds.asset_id = asset_info_mta_rec.asset_number
          and fds.deprn_run_date in ( select max(fds_tmp.DEPRN_RUN_DATE) 
                                        from fa.fa_deprn_summary fds_tmp
                                       where fds_tmp.book_type_code = psi_libro /** '02_AMX_CONTABLE' **/
                                         AND fds_tmp.asset_id = asset_info_mta_rec.asset_number 
                                         and trunc(DEPRN_RUN_DATE) <= ld_period_end_date /**to_date ('31/05/2017','DD/MM/YYYY')**/
                                     )
                                 ;
      
       select fds.deprn_reserve
         into ln_deprn_reserve_usd_mta
         from fa.fa_mc_deprn_summary fds
        where 1= 1
          AND fds.book_type_code = psi_libro /**'02_AMX_CONTABLE' **/ 
          and fds.asset_id = asset_info_mta_rec.asset_number
          and fds.deprn_run_date in ( select max(fds_tmp.DEPRN_RUN_DATE) 
                                        from fa.fa_mc_deprn_summary fds_tmp
                                       where fds_tmp.book_type_code = psi_libro /** '02_AMX_CONTABLE' **/
                                         AND fds_tmp.asset_id = asset_info_mta_rec.asset_number 
                                         and trunc(DEPRN_RUN_DATE) <= ld_period_end_date /**to_date ('31/05/2017','DD/MM/YYYY')**/
                                     )
                                 ;
           
          ln_vnl_mxn_mta := ln_vnl_mxn_mta +(asset_info_mta_rec.costo_mxn-ln_deprn_reserve_mxn_mta);  
          ln_vnl_usd_mta := ln_vnl_usd_mta +(asset_info_mta_rec.costo_usd-ln_deprn_reserve_usd_mta);  
          ln_vnl_dolarizado_mta := ln_vnl_dolarizado_mta + ((asset_info_mta_rec.costo_usd-ln_deprn_reserve_usd_mta)*ln_cierre_rate);
                                
          else 
          ln_vnl_mxn_mta := ln_vnl_mxn_mta +(asset_info_mta_rec.costo_mxn-asset_info_mta_rec.deprn_reserve_mxn);
          ln_vnl_usd_mta := ln_vnl_usd_mta +(asset_info_mta_rec.costo_usd-asset_info_mta_rec.deprn_reserve_usd);
          ln_vnl_dolarizado_mta := ln_vnl_dolarizado_mta +((asset_info_mta_rec.costo_usd-asset_info_mta_rec.deprn_reserve_usd)*ln_cierre_rate); 
           
          end if; 
      
   END LOOP;
   CLOSE get_asset_info;
   
    OPEN get_asset_info(psi_libro,psi_periodo,'MEJORAS PROPIEDADES ARRENDADAS-TERRENOS-FEDERALES');
   LOOP
      FETCH get_asset_info INTO asset_info_mtf_rec;
      EXIT WHEN get_asset_info%NOTFOUND;
      
       if 'FULL RETIREMENT' = asset_info_mtf_rec.ultimo_estado OR 
          'ADJUSTMENT' = asset_info_mtf_rec.ultimo_estado then
           select fds.deprn_reserve
         into ln_deprn_reserve_mxn_mtf
         from fa.fa_deprn_summary fds
        where 1= 1
          AND fds.book_type_code = psi_libro /**'02_AMX_CONTABLE' **/ 
          and fds.asset_id = asset_info_mtf_rec.asset_number
          and fds.deprn_run_date in ( select max(fds_tmp.DEPRN_RUN_DATE) 
                                        from fa.fa_deprn_summary fds_tmp
                                       where fds_tmp.book_type_code = psi_libro /** '02_AMX_CONTABLE' **/
                                         AND fds_tmp.asset_id = asset_info_mtf_rec.asset_number 
                                         and trunc(DEPRN_RUN_DATE) <= ld_period_end_date /**to_date ('31/05/2017','DD/MM/YYYY')**/
                                     )
                                 ;
      
       select fds.deprn_reserve
         into ln_deprn_reserve_usd_mtf
         from fa.fa_mc_deprn_summary fds
        where 1= 1
          AND fds.book_type_code = psi_libro /**'02_AMX_CONTABLE' **/ 
          and fds.asset_id = asset_info_mtf_rec.asset_number
          and fds.deprn_run_date in ( select max(fds_tmp.DEPRN_RUN_DATE) 
                                        from fa.fa_mc_deprn_summary fds_tmp
                                       where fds_tmp.book_type_code = psi_libro /** '02_AMX_CONTABLE' **/
                                         AND fds_tmp.asset_id = asset_info_mtf_rec.asset_number 
                                         and trunc(DEPRN_RUN_DATE) <= ld_period_end_date /**to_date ('31/05/2017','DD/MM/YYYY')**/
                                     )
                                 ;
          ln_vnl_mxn_mtf := ln_vnl_mxn_mtf +(asset_info_mtf_rec.costo_mxn-ln_deprn_reserve_mxn_mtf);  
          ln_vnl_usd_mtf := ln_vnl_usd_mtf +(asset_info_mtf_rec.costo_usd-ln_deprn_reserve_usd_mtf);  
          ln_vnl_dolarizado_mtf := ln_vnl_dolarizado_mtf + ((asset_info_mtf_rec.costo_usd-ln_deprn_reserve_usd_mtf)*ln_cierre_rate);
                                 
          else 
          ln_vnl_mxn_mtf := ln_vnl_mxn_mtf +(asset_info_mtf_rec.costo_mxn-asset_info_mtf_rec.deprn_reserve_mxn);
          ln_vnl_usd_mtf := ln_vnl_usd_mtf +(asset_info_mtf_rec.costo_usd-asset_info_mtf_rec.deprn_reserve_usd);
          ln_vnl_dolarizado_mtf := ln_vnl_dolarizado_mtf +((asset_info_mtf_rec.costo_usd-asset_info_mtf_rec.deprn_reserve_usd)*ln_cierre_rate);
          end if; 
      
   END LOOP;
   CLOSE get_asset_info;
   
   
   ln_prorateo_cmp := (ln_vnl_mxn_cmp+ln_prorateo_mta+ln_vnl_mxn_mtf)/ln_vnl_mxn_cmp; 
   ln_prorateo_mta := (ln_vnl_mxn_cmp+ln_prorateo_mta+ln_vnl_mxn_mtf)/ln_vnl_mxn_mta; 
   ln_prorateo_mtf := (ln_vnl_mxn_cmp+ln_prorateo_mta+ln_vnl_mxn_mtf)/ln_vnl_mxn_mtf; 


exception when others then 
  pso_errmsg := sqlerrm; 
  pso_errcod := '2'; 

end GET_MF_BALANCE; 
                        



END XXGAM_SAF_RUBRO9_PKG; 
/

