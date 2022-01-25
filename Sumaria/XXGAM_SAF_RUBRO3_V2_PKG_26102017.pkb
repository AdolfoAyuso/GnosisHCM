CREATE OR REPLACE package body APPS.XXGAM_SAF_RUBRO3_V2_PKG as

PROCEDURE R3(x_errbuf OUT VARCHAR2, x_retcode OUT NUMBER, p_periodo IN VARCHAR2, psi_divisa IN VARCHAR2) IS

CURSOR cur_clasf IS
SELECT DISTINCT AGRUPADO 
FROM XXGAM_SAF_SETUP
WHERE ID_RUBRO='3';

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
   fnd_file.put_line(fnd_file.output, '<ENCABEZADO>'||'SUMARIA RUBRO 3'||'</ENCABEZADO>');
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
                AND SAF.ID_RUBRO='3'
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
                        ln_last_ytd := APPS.XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(SUBSTR(cur_aux.CUENTA,1,4), SUBSTR(cur_aux.CUENTA,6,10), p_periodo, psi_divisa, '02');
                        fnd_file.put_line(fnd_file.output, '<SALDO_INICIAL>'||ln_last_ytd||'</SALDO_INICIAL>');
                        IF cur_aux.AGRUPADO = 'DPN' THEN 
                            ln_debit:=XXGAM_SAF_UTIL_V1_PKG.ADDITION(cur_aux.CODE_COMBINATION, p_periodo,'GAM_MXN'); -- MODIFICAAAAAAAAAR!!!
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
        fnd_file.put_line(fnd_file.output, '<DEPRECIACION_TOTAL>' || ln_vnl_depreciacion || '</DEPRECIACION_TOTAL>');
        fnd_file.put_line(fnd_file.output, '</CLASIFICACION>');
        
        END LOOP;
        
fnd_file.put_line(fnd_file.output, '<VNL_SALDO_INI>' || ln_vnl_saldo_ini || '</VNL_SALDO_INI>');
fnd_file.put_line(fnd_file.output, '<VNL_PTD>' || ln_vnl_ptd || '</VNL_PTD>');
fnd_file.put_line(fnd_file.output, '<VNL_YTD>' || ln_vnl_ytd || '</VNL_YTD>');
fnd_file.put_line(fnd_file.output, '<VNL_ADICIONES>' || ln_vnl_adiciones || '</VNL_ADICIONES>');
fnd_file.put_line(fnd_file.output, '<VNL_DISMINUCIONES>' || ln_vnl_disminuciones || '</VNL_DISMINUCIONES>');
fnd_file.put_line(fnd_file.output, '<VNL_DEPRECIACION>' || ln_vnl_depreciacion || '</VNL_DEPRECIACION>');
fnd_file.put_line(fnd_file.output, '</REPORTE>');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
               fnd_file.put_line(fnd_file.LOG, 'No hay datos');
    WHEN OTHERS THEN 
               fnd_file.put_line(fnd_file.LOG, sqlerrm);
END;

PROCEDURE EXECUTE_R3(pso_errmsg          out varchar2
                    , pso_errcod          out varchar2
                    , psi_operating_unit  IN VARCHAR2
                    , psi_periodo         IN VARCHAR2
                    , psi_divisa          IN VARCHAR2
                    , pro_tt_by_rubro_rec out xxgam_saf_op_men_pkg.t_by_rubro_rec
                    ) IS

CURSOR cur_clasf IS
SELECT DISTINCT AGRUPADO 
FROM XXGAM_SAF_SETUP
WHERE ID_RUBRO='3';

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

BEGIN


 LT_CATEGORY_TBL(1) :='PARTES Y ACCESORIOS DE AVION-ROTABLES-TIERRA';           /** 1217-16001 **/
 

    BEGIN
    hr_util_misc_web.insert_session_row(sysdate);
    END;
   fnd_file.put_line(fnd_file.log,psi_periodo);
   fnd_file.put_line(fnd_file.log, 'Comienza a Ejecutarse Operacion Mensual Rubro 3');
   FOR cur_max
   IN cur_clasf
   LOOP 
        
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
                AND (SAF.ID_RUBRO='3' OR NVL(SAF.EXCEPTION_ID_RUBRO,0)='3')
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
                        let_inversion_tbl(ln_inversion_idx).rubro := cur_aux.RUBRO;
                        let_inversion_tbl(ln_inversion_idx).num_rubro := cur_aux.NO_RUBRO;
                        let_inversion_tbl(ln_inversion_idx).cuenta := SUBSTR(cur_aux.CUENTA,1,4);
                        let_inversion_tbl(ln_inversion_idx).subcuenta := SUBSTR(cur_aux.CUENTA,6,10);
                        let_inversion_tbl(ln_inversion_idx).concepto := cur_aux.CONCEPTO;
                        ln_last_ytd := APPS.XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(SUBSTR(cur_aux.CUENTA,1,4), SUBSTR(cur_aux.CUENTA,6,10), psi_periodo, psi_divisa, psi_operating_unit);
                        let_inversion_tbl(ln_inversion_idx).saldo_inicial := ln_last_ytd;
                            ln_debit:=APPS.XXGAM_SAF_UTIL_V1_PKG.ADDITION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux);
                            ln_credit:=APPS.XXGAM_SAF_UTIL_V1_PKG.REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux);  
                            --ln_debit := ADDITION(cur_aux.CODE_COMBINATION, psi_periodo);
                            --ln_debit := REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo);                         
                            if (SUBSTR(cur_aux.CUENTA,6,5) = '16001') then
                            
                                if (ln_debit - ln_credit)<0 then
                                     
                                    let_inversion_tbl(ln_inversion_idx).ad_altas :=0;
                                    let_inversion_tbl(ln_inversion_idx).ad_dism_inversa :=  ln_debit - ln_credit;
                                    ln_suma_adiciones := ln_suma_adiciones +0;
                                    ln_vnl_adiciones := ln_vnl_adiciones +0;
                                    ln_suma_disminuciones := ln_suma_disminuciones +  (ln_debit - ln_credit);
                                    ln_vnl_disminuciones := ln_vnl_disminuciones +  (ln_debit - ln_credit);
                                else                                
                                    let_inversion_tbl(ln_inversion_idx).ad_altas :=ln_debit - ln_credit;
                                    let_inversion_tbl(ln_inversion_idx).ad_dism_inversa :=  0;
                                    ln_suma_adiciones := ln_suma_adiciones + (ln_debit - ln_credit);
                                    ln_vnl_adiciones := ln_vnl_adiciones + (ln_debit - ln_credit);
                                    ln_suma_disminuciones := ln_suma_disminuciones + 0;
                                    ln_vnl_disminuciones := ln_vnl_disminuciones + 0;
                                 
                                end if;
                                

                            else
                            
                            let_inversion_tbl(ln_inversion_idx).ad_altas :=ln_debit - ln_credit;
                            let_inversion_tbl(ln_inversion_idx).ad_dism_inversa :=  0;
                            ln_suma_adiciones := ln_suma_adiciones + (ln_debit - ln_credit);
                            ln_vnl_adiciones := ln_vnl_adiciones + (ln_debit - ln_credit);
                            ln_suma_disminuciones := ln_suma_disminuciones + 0;
                            ln_vnl_disminuciones := ln_vnl_disminuciones + 0;
                              
                         end if;
                            /*let_inversion_tbl(ln_inversion_idx).ad_altas := ln_debit - ln_credit;*/
                           /* ln_suma_adiciones := ln_suma_adiciones + (ln_debit - ln_credit);
                            ln_vnl_adiciones := ln_vnl_adiciones + (ln_debit - ln_credit);*/
                            ln_debit:=0;
                            /*let_inversion_tbl(ln_inversion_idx).ad_dism_inversa := 0;*/
                            /*ln_suma_disminuciones := ln_suma_disminuciones + 0;
                            ln_vnl_disminuciones := ln_vnl_disminuciones + 0;*/
                            ln_credit:=0;
                           let_inversion_tbl(ln_inversion_idx).depn_del_ejercicio := 0;
                          let_inversion_tbl(ln_inversion_idx).suma := cur_aux.PTD;
                        let_inversion_tbl(ln_inversion_idx).saldo_final := cur_aux.SALDO_FINAL;
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
                        
                        ln_costo_scrap:=ln_costo_scrap*(-1);
                        ln_costo_x_venta:=ln_costo_x_venta*(-1);
                        ln_costo_scrap_usd:=ln_costo_scrap_usd*(-1);
                        ln_costo_x_venta_usd:=ln_costo_x_venta_usd*(-1);
                        
                        
                        IF PSI_DIVISA='GAM_MXN' THEN
                        
                        let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr := ln_costo_scrap;
                        ln_suma_scrap := ln_suma_scrap + ln_costo_scrap;
                        let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta  := ln_costo_x_venta;
                        ln_suma_venta := ln_suma_venta + ln_costo_x_venta;
                        ln_vnl_scrap := ln_vnl_scrap + ln_costo_scrap;
                        ln_vnl_venta := ln_vnl_venta + ln_costo_x_venta;
                        ln_costo_scrap := 0; 
                        ln_costo_x_venta := 0; 
                        
                        ELSIF PSI_DIVISA='GAM_USD' THEN
                        let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr := ln_costo_scrap_usd;
                        ln_suma_scrap := ln_suma_scrap + ln_costo_scrap_usd;
                        let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta  := ln_costo_x_venta_usd;
                        ln_suma_venta := ln_suma_venta + ln_costo_x_venta_usd;
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
                    ELSIF  cur_aux.AGRUPADO = 'DPN' THEN 
                        ln_dpn_idx := ln_dpn_idx+1;                                          
                        let_depreciacion_tbl(ln_dpn_idx).rubro := cur_aux.RUBRO;
                        let_depreciacion_tbl(ln_dpn_idx).num_rubro := cur_aux.NO_RUBRO;
                        let_depreciacion_tbl(ln_dpn_idx).cuenta := SUBSTR(cur_aux.CUENTA,1,4);
                        let_depreciacion_tbl(ln_dpn_idx).subcuenta := SUBSTR(cur_aux.CUENTA,6,10);
                        let_depreciacion_tbl(ln_dpn_idx).concepto := cur_aux.CONCEPTO;
                        ln_last_ytd := APPS.XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(SUBSTR(cur_aux.CUENTA,1,4), SUBSTR(cur_aux.CUENTA,6,10), psi_periodo, psi_divisa, psi_operating_unit);
                        let_depreciacion_tbl(ln_dpn_idx).saldo_inicial := ln_last_ytd;     
                        
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
                        
                        ln_debit:=APPS.XXGAM_SAF_UTIL_V1_PKG.ADDITION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux);
                        ln_credit:=APPS.XXGAM_SAF_UTIL_V1_PKG.REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo, divisa_aux);        
                        --ln_debit := ADDITION(cur_aux.CODE_COMBINATION, psi_periodo);
                        --ln_debit := REDUCTION(cur_aux.CODE_COMBINATION, psi_periodo);
                        resta:=ln_debit - ln_credit;
                        let_depreciacion_tbl(ln_dpn_idx).depn_del_ejercicio := resta;
                        let_depreciacion_tbl(ln_dpn_idx).ad_altas := 0;
                        let_depreciacion_tbl(ln_dpn_idx).ad_dism_inversa := 0;
                        ln_vnl_depreciacion := ln_vnl_depreciacion + (ln_debit - ln_credit);
                        ln_debit:=0;
                        ln_credit:=0;
                        resta:=0;
                        let_depreciacion_tbl(ln_dpn_idx).suma := cur_aux.PTD;
                        let_depreciacion_tbl(ln_dpn_idx).saldo_final := cur_aux.SALDO_FINAL;
                        ln_suma_saldo_ini := ln_suma_saldo_ini + ln_last_ytd;
                        ln_suma_ptd := ln_suma_ptd + cur_aux.PTD;
                        ln_suma_ytd := ln_suma_ytd + cur_aux.SALDO_FINAL;
                        lc_agrupado := cur_aux.AGRUPADO;
                        ln_vnl_saldo_ini := ln_vnl_saldo_ini + ln_last_ytd;
                        ln_vnl_ptd := ln_vnl_ptd + cur_aux.PTD;
                        ln_vnl_ytd := ln_vnl_ytd + cur_aux.SALDO_FINAL;
                        ln_last_ytd := 0;
                    END IF;                       
                END LOOP;
                END;
        
        IF lc_agrupado='INVERSION' THEN
            let_inv_subtotal_rec.agrupado := lc_agrupado;       
            lc_agrupado:='A';
            let_inv_subtotal_rec.saldo_inicial := ln_suma_saldo_ini;
            ln_suma_saldo_ini:=0;
            let_inv_subtotal_rec.suma := ln_suma_ptd;
            ln_suma_ptd:=0;
            let_inv_subtotal_rec.saldo_final := ln_suma_ytd;
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
            let_dpn_subtotal_rec.saldo_inicial := ln_suma_saldo_ini;
            ln_suma_saldo_ini:=0;
            let_dpn_subtotal_rec.suma := ln_suma_ptd;
            ln_suma_ptd:=0;
            let_dpn_subtotal_rec.saldo_final := ln_suma_ytd;
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
        
let_subtotal_vnl_rec.saldo_inicial := ln_vnl_saldo_ini;
let_subtotal_vnl_rec.suma := ln_vnl_ptd;
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

PROCEDURE EXECUTE_ACUMULADO(pso_errmsg           out varchar2 
                     ,pso_errcod           out varchar2
                     ,psi_operating_unit  IN VARCHAR2
                     ,psi_periodo          IN VARCHAR2 
                     ,psi_divisa            IN VARCHAR2
                     ,pro_tt_by_rubro_rec out xxgam_saf_op_men_pkg.t_by_rubro_rec
                      ) IS

 pti_tt_by_rubro_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec; 

 let_inversion_set_rec         xxgam_saf_op_men_pkg.t_inversion_set_rec        :=  null; 
 let_moneda_funcional_set_rec  xxgam_saf_op_men_pkg.t_moneda_funcional_set_rec :=  null;
 let_depreciacion_set_rec      xxgam_saf_op_men_pkg.t_depreciacion_set_rec     :=  null;
 let_subtotal_vnl_rec            xxgam_saf_op_men_pkg.t_subtotal_vnl_rec;
 
 let_inversion_tbl             xxgam_saf_op_men_pkg.t_inversion_tbl         ;/**:= null;**/
 let_inv_subtotal_rec        xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec;
  
 let_moneda_funcional_tbl      xxgam_saf_op_men_pkg.t_moneda_funcional_tbl  ;/**:= null;**/
 let_mf_subtotal_rec                xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec;
 
 let_depreciacion_tbl          xxgam_saf_op_men_pkg.t_depreciacion_tbl      ;/**:= null;**/
 let_dpn_subtotal_rec         xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec; 
 
 tt_by_rubro_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec; 

 inversion_set_rec         xxgam_saf_op_men_pkg.t_inversion_set_rec        :=  null; 
 moneda_funcional_set_rec  xxgam_saf_op_men_pkg.t_moneda_funcional_set_rec :=  null;
 depreciacion_set_rec      xxgam_saf_op_men_pkg.t_depreciacion_set_rec     :=  null;
 subtotal_vnl_rec            xxgam_saf_op_men_pkg.t_subtotal_vnl_rec;
 
 inversion_tbl             xxgam_saf_op_men_pkg.t_inversion_tbl         ;/**:= null;**/
 inv_subtotal_rec        xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec;
  
 moneda_funcional_tbl      xxgam_saf_op_men_pkg.t_moneda_funcional_tbl  ;/**:= null;**/
 mf_subtotal_rec                xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec;
 
 depreciacion_tbl          xxgam_saf_op_men_pkg.t_depreciacion_tbl      ;/**:= null;**/
 dpn_subtotal_rec         xxgam_saf_op_men_pkg.t_subtotal_agrupado_rec; 
 
  ln_adiciones NUMBER := 0;
  ln_disminuciones NUMBER := 0;
  ln_transferencias NUMBER := 0;
  ln_moi_bajas_scrap NUMBER := 0;
  ln_moi_bajas_x_venta NUMBER := 0;
  ln_dpn_bajas_scrap NUMBER := 0;
  ln_dpn_bajas_x_venta NUMBER := 0;
  ln_dpn_ejercicio NUMBER := 0;
  ln_suma NUMBER := 0;
  
  ln_saldo_inicial NUMBER := 0;
  ln_saldo_final NUMBER := 0;

  ln_adiciones_sub NUMBER := 0;
  ln_disminuciones_sub NUMBER := 0;
  ln_transferencias_sub NUMBER := 0;
  ln_moi_bajas_scrap_sub NUMBER := 0;
  ln_moi_bajas_x_venta_sub NUMBER := 0;
  ln_dpn_bajas_scrap_sub NUMBER := 0;
  ln_dpn_bajas_x_venta_sub NUMBER := 0;
  ln_dpn_ejercicio_sub NUMBER := 0;
  ln_suma_sub NUMBER := 0;
  
  ln_saldo_inicial_sub NUMBER := 0;
  ln_saldo_final_sub NUMBER := 0;
  
  ln_adiciones_vnl NUMBER := 0;
  ln_disminuciones_vnl NUMBER := 0;
  ln_transferencias_vnl NUMBER := 0;
  ln_moi_bajas_scrap_vnl NUMBER := 0;
  ln_moi_bajas_x_venta_vnl NUMBER := 0;
  ln_dpn_bajas_scrap_vnl NUMBER := 0;
  ln_dpn_bajas_x_venta_vnl NUMBER := 0;
  ln_dpn_ejercicio_vnl NUMBER := 0;
  ln_suma_vnl NUMBER := 0;
  
  ln_saldo_inicial_vnl NUMBER := 0;
  ln_saldo_final_vnl NUMBER := 0;  
  
  idx NUMBER := 1;
    
  periodo_aux VARCHAR2(100) := 'ENE-17';
  periodo_final VARCHAR2(100) := NULL;
  fecha_aux DATE := NULL;

BEGIN

  pso_errmsg := null; 
  pso_errcod := '0';
    
  dbms_output.put_line('COMIENZA EJECUCION');

    SELECT DISTINCT END_DATE
    INTO fecha_aux
    FROM GL_PERIODS
    WHERE PERIOD_NAME=psi_periodo;

    dbms_output.put_line('FECHA AUXILIAR: ' || fecha_aux);

   SELECT DISTINCT PERIOD_NAME 
   INTO periodo_final
   FROM GL_PERIODS
   WHERE 1=1
   AND PERIOD_NAME NOT LIKE '%DIC%'
   AND START_DATE=fecha_aux+1;

   dbms_output.put_line('PERIODO FINAL:' ||periodo_final);


  /*INVERSION*/
  
for idx in 1..4  
loop
  
while periodo_aux != periodo_final
LOOP
 APPS.XXGAM_SAF_RUBRO3_V2_PKG.EXECUTE_R3 (pso_errmsg               => pso_errmsg
                                                   ,pso_errcod             => pso_errcod
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => periodo_aux
                                                   ,psi_divisa            => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => pti_tt_by_rubro_rec
                                                   );

  let_inversion_set_rec         := pti_tt_by_rubro_rec.et_inversion_set_rec;
  let_moneda_funcional_set_rec  := pti_tt_by_rubro_rec.et_moneda_funcional_set_rec;
  let_depreciacion_set_rec      := pti_tt_by_rubro_rec.et_depreciacion_set_rec; 
  let_subtotal_vnl_rec          := pti_tt_by_rubro_rec.et_subtotal_vnl_rec;
  
  let_inversion_tbl             := let_inversion_set_rec.et_inversion_tbl;
  let_inv_subtotal_rec          := let_inversion_set_rec.et_subtotal_agrupado_rec;
   
  let_moneda_funcional_tbl      := let_moneda_funcional_set_rec.et_moneda_funcional_tbl;
  let_mf_subtotal_rec           := let_moneda_funcional_set_rec.et_subtotal_agrupado_rec;
  
  let_depreciacion_tbl          := let_depreciacion_set_rec.et_depreciacion_tbl; 
  let_dpn_subtotal_rec          := let_depreciacion_set_rec.et_subtotal_agrupado_rec;

   
        ln_adiciones := ln_adiciones + let_inversion_tbl(idx).ad_altas;
        ln_adiciones_sub := ln_adiciones_sub + let_inversion_tbl(idx).ad_altas;
        ln_adiciones_vnl := ln_adiciones_vnl + let_inversion_tbl(idx).ad_altas;
        
        dbms_output.put_line(let_inversion_tbl(idx).ad_altas);
        inversion_tbl(idx).ad_altas := ln_adiciones;
        
        ln_disminuciones := ln_disminuciones + let_inversion_tbl(idx).ad_dism_inversa;
        ln_disminuciones_sub := ln_disminuciones_sub + let_inversion_tbl(idx).ad_dism_inversa;
        ln_disminuciones_vnl := ln_disminuciones_vnl + let_inversion_tbl(idx).ad_dism_inversa;
        
        dbms_output.put_line(let_inversion_tbl(idx).ad_dism_inversa);
        inversion_tbl(idx).ad_dism_inversa := ln_disminuciones;
        
        ln_transferencias := ln_transferencias + let_inversion_tbl(idx).ad_transferencia;
        ln_transferencias_sub := ln_transferencias_sub + let_inversion_tbl(idx).ad_transferencia;
        ln_transferencias_vnl := ln_transferencias_vnl + let_inversion_tbl(idx).ad_transferencia;
        
        dbms_output.put_line(let_inversion_tbl(idx).ad_transferencia);
        inversion_tbl(idx).ad_transferencia := ln_transferencias;
        
        ln_moi_bajas_scrap := ln_moi_bajas_scrap + let_inversion_tbl(idx).ret_moi_sin_ingr;
        ln_moi_bajas_scrap_sub := ln_moi_bajas_scrap_sub + let_inversion_tbl(idx).ret_moi_sin_ingr;
        ln_moi_bajas_scrap_vnl := ln_moi_bajas_scrap_vnl + let_inversion_tbl(idx).ret_moi_sin_ingr;
        
        dbms_output.put_line(let_inversion_tbl(idx).ret_moi_sin_ingr);
        inversion_tbl(idx).ret_moi_sin_ingr := ln_moi_bajas_scrap;
        
        ln_moi_bajas_x_venta := ln_moi_bajas_x_venta + let_inversion_tbl(idx).ret_moi_x_venta;
        ln_moi_bajas_x_venta_sub := ln_moi_bajas_x_venta_sub + let_inversion_tbl(idx).ret_moi_x_venta;
        ln_moi_bajas_x_venta_vnl := ln_moi_bajas_x_venta_vnl + let_inversion_tbl(idx).ret_moi_x_venta;
        
        dbms_output.put_line(let_inversion_tbl(idx).ret_moi_x_venta);    
        inversion_tbl(idx).ret_moi_x_venta :=  ln_moi_bajas_x_venta;   
        
        ln_dpn_bajas_scrap := ln_dpn_bajas_scrap + let_inversion_tbl(idx).ret_dpn_sin_ingr;
        ln_dpn_bajas_scrap_sub := ln_dpn_bajas_scrap_sub + let_inversion_tbl(idx).ret_dpn_sin_ingr;
        ln_dpn_bajas_scrap_vnl := ln_dpn_bajas_scrap_vnl + let_inversion_tbl(idx).ret_dpn_sin_ingr; 
        
        dbms_output.put_line(let_inversion_tbl(idx).ret_dpn_sin_ingr);
        inversion_tbl(idx).ret_dpn_sin_ingr := ln_dpn_bajas_scrap;
        
        ln_dpn_bajas_x_venta := ln_dpn_bajas_x_venta + let_inversion_tbl(idx).ret_dpn_x_venta;
        ln_dpn_bajas_x_venta_sub := ln_dpn_bajas_x_venta_sub + let_inversion_tbl(idx).ret_dpn_x_venta;
        ln_dpn_bajas_x_venta_vnl := ln_dpn_bajas_x_venta_vnl + let_inversion_tbl(idx).ret_dpn_x_venta;
        
        dbms_output.put_line(let_inversion_tbl(idx).ret_dpn_x_venta);
        inversion_tbl(idx).ret_dpn_x_venta := ln_dpn_bajas_x_venta;
        
        ln_dpn_ejercicio := ln_dpn_ejercicio + let_inversion_tbl(idx).depn_del_ejercicio;
        ln_dpn_ejercicio_sub := ln_dpn_ejercicio_sub + let_inversion_tbl(idx).depn_del_ejercicio;
        ln_dpn_ejercicio_vnl := ln_dpn_ejercicio_vnl + let_inversion_tbl(idx).depn_del_ejercicio;
        
        dbms_output.put_line(let_inversion_tbl(idx).depn_del_ejercicio);
        inversion_tbl(idx).depn_del_ejercicio := ln_dpn_ejercicio;
        
        ln_suma := ln_suma + let_inversion_tbl(idx).suma;
        ln_suma_sub := ln_suma_sub + let_inversion_tbl(idx).suma;
        ln_suma_vnl := ln_suma_vnl + let_inversion_tbl(idx).suma;   
        
        dbms_output.put_line(let_inversion_tbl(idx).suma);   
        inversion_tbl(idx).suma := ln_suma;
         
    SELECT DISTINCT END_DATE
    INTO fecha_aux
    FROM GL_PERIODS
    WHERE PERIOD_NAME=periodo_aux;
    
    dbms_output.put_line('FECHA AUXILIAR: ' || fecha_aux);

   SELECT DISTINCT PERIOD_NAME 
   INTO periodo_aux
   FROM GL_PERIODS
   WHERE 1=1
   AND PERIOD_NAME NOT LIKE '%DIC%'
   AND START_DATE=fecha_aux+1;
   
   dbms_output.put_line('PERIODO AUXILIAR:' ||periodo_aux);

END LOOP;

   dbms_output.put_line('<INF_RUBRO>'||let_inversion_tbl(idx).rubro||'</INF_RUBRO>');
   dbms_output.put_line('<ID_RUBRO>'||let_inversion_tbl(idx).num_rubro||'</ID_RUBRO>');
   dbms_output.put_line('<CUENTA>'||let_inversion_tbl(idx).cuenta||'-'||let_inversion_tbl(idx).subcuenta||'</CUENTA>'); 
   dbms_output.put_line('<CONCEPTO>'||let_inversion_tbl(idx).concepto||'</CONCEPTO>');
--SALDO INICIAL
   dbms_output.put_line('<DEB_AC>'||ln_adiciones||'</DEB_AC>');
   dbms_output.put_line('<CRED>'||ln_disminuciones||'</CRED>');
--TRANSFERENCIA
   dbms_output.put_line('<RET_MOI_SIN_INGR_ATTR>'||ln_moi_bajas_scrap||'</RET_MOI_SIN_INGR_ATTR>');
   dbms_output.put_line('<RET_MOI_X_VENTA_ATTR>'||ln_moi_bajas_x_venta||'</RET_MOI_X_VENTA_ATTR>');
   dbms_output.put_line('<RET_DPN_SIN_INGR_ATTR>'||ln_dpn_bajas_scrap||'</RET_DPN_SIN_INGR_ATTR>');
   dbms_output.put_line('<RET_DPN_X_VENTA_ATTR>'||ln_dpn_bajas_x_venta||'</RET_DPN_X_VENTA_ATTR>');
   dbms_output.put_line('<DPN>'||ln_dpn_ejercicio||'</DPN>');
   dbms_output.put_line('<ACUM_PERIOD>'||ln_suma||'</ACUM_PERIOD>');
   
        inversion_tbl(idx).rubro := let_inversion_tbl(idx).rubro;
        inversion_tbl(idx).num_rubro := let_inversion_tbl(idx).num_rubro;
        inversion_tbl(idx).cuenta := let_inversion_tbl(idx).cuenta;
        inversion_tbl(idx).subcuenta := let_inversion_tbl(idx).subcuenta;
        inversion_tbl(idx).concepto := let_inversion_tbl(idx).concepto;
   
   --COMIENZA EL CALCULO DE SALDO INICIAL Y FINAL
        
        ln_saldo_inicial :=  XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(let_inversion_tbl(idx).cuenta, let_inversion_tbl(idx).subcuenta, 'ENE-17', psi_divisa, psi_operating_unit);
        ln_saldo_inicial_sub := ln_saldo_inicial_sub + ln_saldo_inicial;
        ln_saldo_inicial_vnl := ln_saldo_inicial_vnl + ln_saldo_inicial;
        
        inversion_tbl(idx).saldo_inicial := ln_saldo_inicial;
        
        ln_saldo_final :=  XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(let_inversion_tbl(idx).cuenta, let_inversion_tbl(idx).subcuenta, periodo_aux, psi_divisa, psi_operating_unit);
        ln_saldo_final_sub := ln_saldo_final_sub + ln_saldo_final;
        ln_saldo_final_vnl := ln_saldo_final_vnl + ln_saldo_final;
        
        inversion_tbl(idx).saldo_final := ln_saldo_final;
        
        --TERMINA EL CALCULO DE SALDO INICIAL Y FINAL

  periodo_aux := 'ENE-17';
  
  ln_adiciones := 0;
  ln_disminuciones := 0;
  ln_transferencias := 0;
  ln_moi_bajas_scrap := 0;
  ln_moi_bajas_x_venta := 0;
  ln_dpn_bajas_scrap := 0;
  ln_dpn_bajas_x_venta := 0;
  ln_dpn_ejercicio := 0;
  ln_suma := 0;
  ln_saldo_inicial := 0;
  ln_saldo_final := 0;

end loop;

inv_subtotal_rec.ad_altas := ln_adiciones_sub;
inv_subtotal_rec.ad_dism_inversa := ln_disminuciones_sub;
inv_subtotal_rec.ad_transferencia := ln_transferencias_sub;
inv_subtotal_rec.ret_moi_sin_ingr := ln_moi_bajas_scrap_sub;
inv_subtotal_rec.ret_moi_x_venta := ln_moi_bajas_x_venta_sub;
inv_subtotal_rec.ret_dpn_sin_ingr := ln_dpn_bajas_scrap_sub;
inv_subtotal_rec.ret_dpn_x_venta := ln_dpn_bajas_x_venta_sub;
inv_subtotal_rec.depn_del_ejercicio := ln_dpn_ejercicio_sub;
inv_subtotal_rec.suma := ln_suma_sub;

inv_subtotal_rec.saldo_inicial := ln_saldo_inicial_sub;
inv_subtotal_rec.saldo_final := ln_saldo_final_sub;

  ln_adiciones_sub := 0;
  ln_disminuciones_sub := 0;
  ln_transferencias_sub := 0;
  ln_moi_bajas_scrap_sub := 0;
  ln_moi_bajas_x_venta_sub := 0;
  ln_dpn_bajas_scrap_sub := 0;
  ln_dpn_bajas_x_venta_sub := 0;
  ln_dpn_ejercicio_sub := 0;
  ln_suma_sub := 0;

  ln_saldo_inicial_sub := 0;
  ln_saldo_final_sub := 0;

    idx := 1;

  /*MONEDA FUNCIONAL*/
  
for idx in 1..3  
loop
  
while periodo_aux != periodo_final
LOOP
 APPS.XXGAM_SAF_RUBRO3_V2_PKG.EXECUTE_R3 (pso_errmsg               => pso_errmsg
                                                   ,pso_errcod             => pso_errcod
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => periodo_aux
                                                   ,psi_divisa            => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => pti_tt_by_rubro_rec
                                                   );

  let_inversion_set_rec         := pti_tt_by_rubro_rec.et_inversion_set_rec;
  let_moneda_funcional_set_rec  := pti_tt_by_rubro_rec.et_moneda_funcional_set_rec;
  let_depreciacion_set_rec      := pti_tt_by_rubro_rec.et_depreciacion_set_rec; 
  let_subtotal_vnl_rec          := pti_tt_by_rubro_rec.et_subtotal_vnl_rec;
  
  let_inversion_tbl             := let_inversion_set_rec.et_inversion_tbl;
  let_inv_subtotal_rec          := let_inversion_set_rec.et_subtotal_agrupado_rec;
   
  let_moneda_funcional_tbl      := let_moneda_funcional_set_rec.et_moneda_funcional_tbl;
  let_mf_subtotal_rec           := let_moneda_funcional_set_rec.et_subtotal_agrupado_rec;
  
  let_depreciacion_tbl          := let_depreciacion_set_rec.et_depreciacion_tbl; 
  let_dpn_subtotal_rec          := let_depreciacion_set_rec.et_subtotal_agrupado_rec;

   
        ln_adiciones := ln_adiciones + let_moneda_funcional_tbl(idx).ad_altas;
        ln_adiciones_sub := ln_adiciones_sub + let_moneda_funcional_tbl(idx).ad_altas;
        ln_adiciones_vnl := ln_adiciones_vnl + let_moneda_funcional_tbl(idx).ad_altas;
        
        dbms_output.put_line(let_moneda_funcional_tbl(idx).ad_altas);
        moneda_funcional_tbl(idx).ad_altas := ln_adiciones;
        
        ln_disminuciones := ln_disminuciones + let_moneda_funcional_tbl(idx).ad_dism_inversa;
        ln_disminuciones_sub := ln_disminuciones_sub + let_moneda_funcional_tbl(idx).ad_dism_inversa;
        ln_disminuciones_vnl := ln_disminuciones_vnl + let_moneda_funcional_tbl(idx).ad_dism_inversa;
        
        dbms_output.put_line(let_moneda_funcional_tbl(idx).ad_dism_inversa);
        moneda_funcional_tbl(idx).ad_dism_inversa := ln_disminuciones;
        
        ln_transferencias := ln_transferencias + let_moneda_funcional_tbl(idx).ad_transferencia;
        ln_transferencias_sub := ln_transferencias_sub + let_moneda_funcional_tbl(idx).ad_transferencia;
        ln_transferencias_vnl := ln_transferencias_vnl + let_moneda_funcional_tbl(idx).ad_transferencia;
        
        dbms_output.put_line(let_moneda_funcional_tbl(idx).ad_transferencia);
        moneda_funcional_tbl(idx).ad_transferencia := ln_transferencias;
        
        ln_moi_bajas_scrap := ln_moi_bajas_scrap + let_moneda_funcional_tbl(idx).ret_moi_sin_ingr;
        ln_moi_bajas_scrap_sub := ln_moi_bajas_scrap_sub + let_moneda_funcional_tbl(idx).ret_moi_sin_ingr;
        ln_moi_bajas_scrap_vnl := ln_moi_bajas_scrap_vnl + let_moneda_funcional_tbl(idx).ret_moi_sin_ingr;
          
        dbms_output.put_line(let_moneda_funcional_tbl(idx).ret_moi_sin_ingr);
        moneda_funcional_tbl(idx).ret_moi_sin_ingr := ln_moi_bajas_scrap;
        
        ln_moi_bajas_x_venta := ln_moi_bajas_x_venta + let_moneda_funcional_tbl(idx).ret_moi_x_venta;
        ln_moi_bajas_x_venta_sub := ln_moi_bajas_x_venta_sub + let_moneda_funcional_tbl(idx).ret_moi_x_venta;
        ln_moi_bajas_x_venta_vnl := ln_moi_bajas_x_venta_vnl + let_moneda_funcional_tbl(idx).ret_moi_x_venta;
        
        dbms_output.put_line(let_moneda_funcional_tbl(idx).ret_moi_x_venta);
        moneda_funcional_tbl(idx).ret_moi_x_venta := ln_moi_bajas_x_venta;
        
        ln_dpn_bajas_scrap := ln_dpn_bajas_scrap + let_moneda_funcional_tbl(idx).ret_dpn_sin_ingr;
        ln_dpn_bajas_scrap_sub := ln_dpn_bajas_scrap_sub + let_moneda_funcional_tbl(idx).ret_dpn_sin_ingr;
        ln_dpn_bajas_scrap_vnl := ln_dpn_bajas_scrap_vnl + let_moneda_funcional_tbl(idx).ret_dpn_sin_ingr;
        
        dbms_output.put_line(let_moneda_funcional_tbl(idx).ret_dpn_sin_ingr);
        moneda_funcional_tbl(idx).ret_dpn_sin_ingr := ln_dpn_bajas_scrap;
        
        ln_dpn_bajas_x_venta := ln_dpn_bajas_x_venta + let_moneda_funcional_tbl(idx).ret_dpn_x_venta;
        ln_dpn_bajas_x_venta_sub := ln_dpn_bajas_x_venta_sub + let_moneda_funcional_tbl(idx).ret_dpn_x_venta;
        ln_dpn_bajas_x_venta_vnl := ln_dpn_bajas_x_venta_vnl + let_moneda_funcional_tbl(idx).ret_dpn_x_venta;
        
        dbms_output.put_line(let_moneda_funcional_tbl(idx).ret_dpn_x_venta);
        moneda_funcional_tbl(idx).ret_dpn_x_venta := ln_dpn_bajas_x_venta;
        
        ln_dpn_ejercicio := ln_dpn_ejercicio + let_moneda_funcional_tbl(idx).depn_del_ejercicio;
        ln_dpn_ejercicio_sub := ln_dpn_ejercicio_sub + let_moneda_funcional_tbl(idx).depn_del_ejercicio;
        ln_dpn_ejercicio_vnl := ln_dpn_ejercicio_vnl + let_moneda_funcional_tbl(idx).depn_del_ejercicio;
        
        dbms_output.put_line(let_moneda_funcional_tbl(idx).depn_del_ejercicio);
        moneda_funcional_tbl(idx).depn_del_ejercicio := ln_dpn_ejercicio;
        
        ln_suma := ln_suma + let_moneda_funcional_tbl(idx).suma; 
        ln_suma_sub := ln_suma_sub + let_moneda_funcional_tbl(idx).suma;
        ln_suma_vnl := ln_suma_vnl + let_moneda_funcional_tbl(idx).suma;
        
        dbms_output.put_line(let_moneda_funcional_tbl(idx).suma);   
        moneda_funcional_tbl(idx).suma := ln_suma;
 
    SELECT DISTINCT END_DATE
    INTO fecha_aux
    FROM GL_PERIODS
    WHERE PERIOD_NAME=periodo_aux;
    
    dbms_output.put_line('FECHA AUXILIAR: ' || fecha_aux);

   SELECT DISTINCT PERIOD_NAME 
   INTO periodo_aux
   FROM GL_PERIODS
   WHERE 1=1
   AND PERIOD_NAME NOT LIKE '%DIC%'
   AND START_DATE=fecha_aux+1;
   
   dbms_output.put_line('PERIODO AUXILIAR:' ||periodo_aux);

END LOOP;

   dbms_output.put_line('<INF_RUBRO>'||let_moneda_funcional_tbl(idx).rubro||'</INF_RUBRO>');
   dbms_output.put_line('<ID_RUBRO>'||let_moneda_funcional_tbl(idx).num_rubro||'</ID_RUBRO>');
   dbms_output.put_line('<CUENTA>'||let_moneda_funcional_tbl(idx).cuenta||'-'||let_moneda_funcional_tbl(idx).subcuenta||'</CUENTA>'); 
   dbms_output.put_line('<CONCEPTO>'||let_moneda_funcional_tbl(idx).concepto||'</CONCEPTO>');
--SALDO INICIAL
   dbms_output.put_line('<DEB_AC>'||ln_adiciones||'</DEB_AC>');
   dbms_output.put_line('<CRED>'||ln_disminuciones||'</CRED>');
--TRANSFERENCIA
   dbms_output.put_line('<RET_MOI_SIN_INGR_ATTR>'||ln_moi_bajas_scrap||'</RET_MOI_SIN_INGR_ATTR>');
   dbms_output.put_line('<RET_MOI_X_VENTA_ATTR>'||ln_moi_bajas_x_venta||'</RET_MOI_X_VENTA_ATTR>');
   dbms_output.put_line('<RET_DPN_SIN_INGR_ATTR>'||ln_dpn_bajas_scrap||'</RET_DPN_SIN_INGR_ATTR>');
   dbms_output.put_line('<RET_DPN_X_VENTA_ATTR>'||ln_dpn_bajas_x_venta||'</RET_DPN_X_VENTA_ATTR>');
   dbms_output.put_line('<DPN>'||ln_dpn_ejercicio||'</DPN>');
   dbms_output.put_line('<ACUM_PERIOD>'||ln_suma||'</ACUM_PERIOD>');
   
        moneda_funcional_tbl(idx).rubro := let_moneda_funcional_tbl(idx).rubro;
        moneda_funcional_tbl(idx).num_rubro := let_moneda_funcional_tbl(idx).num_rubro;
        moneda_funcional_tbl(idx).cuenta := let_moneda_funcional_tbl(idx).cuenta;
        moneda_funcional_tbl(idx).subcuenta := let_moneda_funcional_tbl(idx).subcuenta;
        moneda_funcional_tbl(idx).concepto := let_moneda_funcional_tbl(idx).concepto;

   --COMIENZA EL CALCULO DE SALDO INICIAL Y FINAL
        
        ln_saldo_inicial :=  XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(let_moneda_funcional_tbl(idx).cuenta,let_moneda_funcional_tbl(idx).subcuenta, 'ENE-17', psi_divisa, psi_operating_unit);
        ln_saldo_inicial_sub := ln_saldo_inicial_sub + ln_saldo_inicial;
        ln_saldo_inicial_vnl := ln_saldo_inicial_vnl + ln_saldo_inicial;
        
        moneda_funcional_tbl(idx).saldo_inicial := ln_saldo_inicial;
        
        ln_saldo_final :=  XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(let_moneda_funcional_tbl(idx).cuenta, let_moneda_funcional_tbl(idx).subcuenta, periodo_aux, psi_divisa, psi_operating_unit);
        ln_saldo_final_sub := ln_saldo_final_sub + ln_saldo_final;
        ln_saldo_final_vnl := ln_saldo_final_vnl + ln_saldo_final;
        
        moneda_funcional_tbl(idx).saldo_final := ln_saldo_final;
        
        --TERMINA EL CALCULO DE SALDO INICIAL Y FINAL

  periodo_aux := 'ENE-17';
  
  ln_adiciones := 0;
  ln_disminuciones := 0;
  ln_transferencias := 0;
  ln_moi_bajas_scrap := 0;
  ln_moi_bajas_x_venta := 0;
  ln_dpn_bajas_scrap := 0;
  ln_dpn_bajas_x_venta := 0;
  ln_dpn_ejercicio := 0;
  ln_suma := 0;
  
  ln_saldo_inicial := 0;
  ln_saldo_final := 0;


end loop;

mf_subtotal_rec.ad_altas := ln_adiciones_sub;
mf_subtotal_rec.ad_dism_inversa := ln_disminuciones_sub;
mf_subtotal_rec.ad_transferencia := ln_transferencias_sub;
mf_subtotal_rec.ret_moi_sin_ingr := ln_moi_bajas_scrap_sub;
mf_subtotal_rec.ret_moi_x_venta := ln_moi_bajas_x_venta_sub;
mf_subtotal_rec.ret_dpn_sin_ingr := ln_dpn_bajas_scrap_sub;
mf_subtotal_rec.ret_dpn_x_venta := ln_dpn_bajas_x_venta_sub;
mf_subtotal_rec.depn_del_ejercicio := ln_dpn_ejercicio_sub;
mf_subtotal_rec.suma := ln_suma_sub;

mf_subtotal_rec.saldo_inicial := ln_saldo_inicial_sub;
mf_subtotal_rec.saldo_final := ln_saldo_final_sub;

  ln_adiciones_sub := 0;
  ln_disminuciones_sub := 0;
  ln_transferencias_sub := 0;
  ln_moi_bajas_scrap_sub := 0;
  ln_moi_bajas_x_venta_sub := 0;
  ln_dpn_bajas_scrap_sub := 0;
  ln_dpn_bajas_x_venta_sub := 0;
  ln_dpn_ejercicio_sub := 0;
  ln_suma_sub := 0;
  
  ln_saldo_inicial_sub := 0;
  ln_saldo_final_sub := 0;

idx := 1;

  /*DEPRECIACION */
  
for idx in 1..1  
loop
  
while periodo_aux != periodo_final
LOOP
 APPS.XXGAM_SAF_RUBRO3_V2_PKG.EXECUTE_R3 (pso_errmsg               => pso_errmsg
                                                   ,pso_errcod             => pso_errcod
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => periodo_aux
                                                   ,psi_divisa            => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => pti_tt_by_rubro_rec
                                                   );

  let_inversion_set_rec         := pti_tt_by_rubro_rec.et_inversion_set_rec;
  let_moneda_funcional_set_rec  := pti_tt_by_rubro_rec.et_moneda_funcional_set_rec;
  let_depreciacion_set_rec      := pti_tt_by_rubro_rec.et_depreciacion_set_rec; 
  let_subtotal_vnl_rec          := pti_tt_by_rubro_rec.et_subtotal_vnl_rec;
  
  let_inversion_tbl             := let_inversion_set_rec.et_inversion_tbl;
  let_inv_subtotal_rec          := let_inversion_set_rec.et_subtotal_agrupado_rec;
   
  let_moneda_funcional_tbl      := let_moneda_funcional_set_rec.et_moneda_funcional_tbl;
  let_mf_subtotal_rec           := let_moneda_funcional_set_rec.et_subtotal_agrupado_rec;
  
  let_depreciacion_tbl          := let_depreciacion_set_rec.et_depreciacion_tbl; 
  let_dpn_subtotal_rec          := let_depreciacion_set_rec.et_subtotal_agrupado_rec;

   
        ln_adiciones := ln_adiciones + let_depreciacion_tbl(idx).ad_altas;
        ln_adiciones_sub := ln_adiciones_sub + let_depreciacion_tbl(idx).ad_altas;
        ln_adiciones_vnl := ln_adiciones_vnl + let_depreciacion_tbl(idx).ad_altas;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).ad_altas);
        depreciacion_tbl(idx).ad_altas := ln_adiciones;
        
        ln_disminuciones := ln_disminuciones + let_depreciacion_tbl(idx).ad_dism_inversa;
        ln_disminuciones_sub := ln_disminuciones_sub + let_depreciacion_tbl(idx).ad_dism_inversa;
        ln_disminuciones_vnl := ln_disminuciones_vnl + let_depreciacion_tbl(idx).ad_dism_inversa;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).ad_dism_inversa);
        depreciacion_tbl(idx).ad_dism_inversa := ln_disminuciones;
        
        ln_transferencias := ln_transferencias + let_depreciacion_tbl(idx).ad_transferencia;
        ln_transferencias_sub := ln_transferencias_sub + let_depreciacion_tbl(idx).ad_transferencia;
        ln_transferencias_vnl := ln_transferencias_vnl + let_depreciacion_tbl(idx).ad_transferencia;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).ad_transferencia);
        depreciacion_tbl(idx).ad_transferencia := ln_transferencias;
        
        ln_moi_bajas_scrap := ln_moi_bajas_scrap + let_depreciacion_tbl(idx).ret_moi_sin_ingr;
        ln_moi_bajas_scrap_sub := ln_moi_bajas_scrap_sub + let_depreciacion_tbl(idx).ret_moi_sin_ingr;
        ln_moi_bajas_scrap_vnl := ln_moi_bajas_scrap_vnl + let_depreciacion_tbl(idx).ret_moi_sin_ingr;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).ret_moi_sin_ingr);
        depreciacion_tbl(idx).ret_moi_sin_ingr := ln_moi_bajas_scrap;
        
        ln_moi_bajas_x_venta := ln_moi_bajas_x_venta + let_depreciacion_tbl(idx).ret_moi_x_venta;
        ln_moi_bajas_x_venta_sub := ln_moi_bajas_x_venta_sub + let_depreciacion_tbl(idx).ret_moi_x_venta;
        ln_moi_bajas_x_venta_vnl := ln_moi_bajas_x_venta_vnl + let_depreciacion_tbl(idx).ret_moi_x_venta;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).ret_moi_x_venta);
        depreciacion_tbl(idx).ret_moi_x_venta := ln_moi_bajas_x_venta;
        
        ln_dpn_bajas_scrap := ln_dpn_bajas_scrap + let_depreciacion_tbl(idx).ret_dpn_sin_ingr;
        ln_dpn_bajas_scrap_sub := ln_dpn_bajas_scrap_sub + let_depreciacion_tbl(idx).ret_dpn_sin_ingr;
        ln_dpn_bajas_scrap_vnl := ln_dpn_bajas_scrap_vnl + let_depreciacion_tbl(idx).ret_dpn_sin_ingr;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).ret_dpn_sin_ingr);
        depreciacion_tbl(idx).ret_dpn_sin_ingr := ln_dpn_bajas_scrap;
        
        ln_dpn_bajas_x_venta := ln_dpn_bajas_x_venta + let_depreciacion_tbl(idx).ret_dpn_x_venta;
        ln_dpn_bajas_x_venta_sub := ln_dpn_bajas_x_venta_sub + let_depreciacion_tbl(idx).ret_dpn_x_venta;
        ln_dpn_bajas_x_venta_vnl := ln_dpn_bajas_x_venta_vnl + let_depreciacion_tbl(idx).ret_dpn_x_venta;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).ret_dpn_x_venta);
        depreciacion_tbl(idx).ret_dpn_x_venta := ln_dpn_bajas_x_venta;
        
        ln_dpn_ejercicio := ln_dpn_ejercicio + let_depreciacion_tbl(idx).depn_del_ejercicio;
        ln_dpn_ejercicio_sub := ln_dpn_ejercicio_sub + let_depreciacion_tbl(idx).depn_del_ejercicio;
        ln_dpn_ejercicio_vnl := ln_dpn_ejercicio_vnl + let_depreciacion_tbl(idx).depn_del_ejercicio;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).depn_del_ejercicio);
        depreciacion_tbl(idx).depn_del_ejercicio := ln_dpn_ejercicio;       
        
        ln_suma := ln_suma + let_depreciacion_tbl(idx).suma;   
        ln_suma_sub := ln_suma_sub + let_depreciacion_tbl(idx).suma;
        ln_suma_vnl := ln_suma_vnl + let_depreciacion_tbl(idx).suma;
        
        dbms_output.put_line(let_depreciacion_tbl(idx).suma);   
        depreciacion_tbl(idx).suma := ln_suma;
  
    SELECT DISTINCT END_DATE
    INTO fecha_aux
    FROM GL_PERIODS
    WHERE PERIOD_NAME=periodo_aux;
    
    dbms_output.put_line('FECHA AUXILIAR: ' || fecha_aux);

   SELECT DISTINCT PERIOD_NAME 
   INTO periodo_aux
   FROM GL_PERIODS
   WHERE 1=1
   AND PERIOD_NAME NOT LIKE '%DIC%'
   AND START_DATE=fecha_aux+1;
   
   dbms_output.put_line('PERIODO AUXILIAR:' ||periodo_aux);

END LOOP;

   dbms_output.put_line('<INF_RUBRO>'||let_depreciacion_tbl(idx).rubro||'</INF_RUBRO>');
   dbms_output.put_line('<ID_RUBRO>'||let_depreciacion_tbl(idx).num_rubro||'</ID_RUBRO>');
   dbms_output.put_line('<CUENTA>'||let_depreciacion_tbl(idx).cuenta||'-'||let_depreciacion_tbl(idx).subcuenta||'</CUENTA>'); 
   dbms_output.put_line('<CONCEPTO>'||let_depreciacion_tbl(idx).concepto||'</CONCEPTO>');
--SALDO INICIAL
   dbms_output.put_line('<DEB_AC>'||ln_adiciones||'</DEB_AC>');
   dbms_output.put_line('<CRED>'||ln_disminuciones||'</CRED>');
--TRANSFERENCIA
   dbms_output.put_line('<RET_MOI_SIN_INGR_ATTR>'||ln_moi_bajas_scrap||'</RET_MOI_SIN_INGR_ATTR>');
   dbms_output.put_line('<RET_MOI_X_VENTA_ATTR>'||ln_moi_bajas_x_venta||'</RET_MOI_X_VENTA_ATTR>');
   dbms_output.put_line('<RET_DPN_SIN_INGR_ATTR>'||ln_dpn_bajas_scrap||'</RET_DPN_SIN_INGR_ATTR>');
   dbms_output.put_line('<RET_DPN_X_VENTA_ATTR>'||ln_dpn_bajas_x_venta||'</RET_DPN_X_VENTA_ATTR>');
   dbms_output.put_line('<DPN>'||ln_dpn_ejercicio||'</DPN>');
   dbms_output.put_line('<ACUM_PERIOD>'||ln_suma||'</ACUM_PERIOD>');
   
        depreciacion_tbl(idx).rubro := let_depreciacion_tbl(idx).rubro;
        depreciacion_tbl(idx).num_rubro := let_depreciacion_tbl(idx).num_rubro;
        depreciacion_tbl(idx).cuenta := let_depreciacion_tbl(idx).cuenta;
        depreciacion_tbl(idx).subcuenta := let_depreciacion_tbl(idx).subcuenta;
        depreciacion_tbl(idx).concepto := let_depreciacion_tbl(idx).concepto;

        --COMIENZA EL CALCULO DE SALDO INICIAL Y FINAL
        
        ln_saldo_inicial :=  XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(let_depreciacion_tbl(idx).cuenta,let_depreciacion_tbl(idx).subcuenta, 'ENE-17', psi_divisa, psi_operating_unit);
        ln_saldo_inicial_sub := ln_saldo_inicial_sub + ln_saldo_inicial;
        ln_saldo_inicial_vnl := ln_saldo_inicial_vnl + ln_saldo_inicial;
        
        depreciacion_tbl(idx).saldo_inicial := ln_saldo_inicial;
        
        ln_saldo_final :=  XXGAM_SAF_UTIL_V1_PKG.LAST_YTD(let_depreciacion_tbl(idx).cuenta, let_depreciacion_tbl(idx).subcuenta, periodo_aux, psi_divisa, psi_operating_unit);
        ln_saldo_final_sub := ln_saldo_final_sub + ln_saldo_final;
        ln_saldo_final_vnl := ln_saldo_final_vnl + ln_saldo_final;
        
        depreciacion_tbl(idx).saldo_final := ln_saldo_final;
        
        --TERMINA EL CALCULO DE SALDO INICIAL Y FINAL

  periodo_aux := 'ENE-17';
  
  ln_adiciones := 0;
  ln_disminuciones := 0;
  ln_transferencias := 0;
  ln_moi_bajas_scrap := 0;
  ln_moi_bajas_x_venta := 0;
  ln_dpn_bajas_scrap := 0;
  ln_dpn_bajas_x_venta := 0;
  ln_dpn_ejercicio := 0;
  ln_suma := 0;
  
  ln_saldo_inicial := 0;
  ln_saldo_final := 0;


end loop;

dpn_subtotal_rec.ad_altas := ln_adiciones_sub;
dpn_subtotal_rec.ad_dism_inversa := ln_disminuciones_sub;
dpn_subtotal_rec.ad_transferencia := ln_transferencias_sub;
dpn_subtotal_rec.ret_moi_sin_ingr := ln_moi_bajas_scrap_sub;
dpn_subtotal_rec.ret_moi_x_venta := ln_moi_bajas_x_venta_sub;
dpn_subtotal_rec.ret_dpn_sin_ingr := ln_dpn_bajas_scrap_sub;
dpn_subtotal_rec.ret_dpn_x_venta := ln_dpn_bajas_x_venta_sub;
dpn_subtotal_rec.depn_del_ejercicio := ln_dpn_ejercicio_sub;
dpn_subtotal_rec.suma := ln_suma_sub;

dpn_subtotal_rec.saldo_inicial := ln_saldo_inicial_sub;
dpn_subtotal_rec.saldo_final := ln_saldo_final_sub;

  ln_adiciones_sub := 0;
  ln_disminuciones_sub := 0;
  ln_transferencias_sub := 0;
  ln_moi_bajas_scrap_sub := 0;
  ln_moi_bajas_x_venta_sub := 0;
  ln_dpn_bajas_scrap_sub := 0;
  ln_dpn_bajas_x_venta_sub := 0;
  ln_dpn_ejercicio_sub := 0;
  ln_suma_sub := 0;
  
  ln_saldo_inicial_sub := 0;
  ln_saldo_final_sub := 0;
  
subtotal_vnl_rec.ad_altas := ln_adiciones_vnl;
subtotal_vnl_rec.ad_dism_inversa := ln_disminuciones_vnl;
subtotal_vnl_rec.ad_transferencia := ln_transferencias_vnl;
subtotal_vnl_rec.ret_moi_sin_ingr := ln_moi_bajas_scrap_vnl;
subtotal_vnl_rec.ret_moi_x_venta := ln_moi_bajas_x_venta_vnl;
subtotal_vnl_rec.ret_dpn_sin_ingr := ln_dpn_bajas_scrap_vnl;
subtotal_vnl_rec.ret_dpn_x_venta := ln_dpn_bajas_x_venta_vnl;
subtotal_vnl_rec.depn_del_ejercicio := ln_dpn_ejercicio_vnl;
subtotal_vnl_rec.suma := ln_suma_vnl;

subtotal_vnl_rec.saldo_inicial := ln_saldo_inicial_vnl;
subtotal_vnl_rec.saldo_final := ln_saldo_final_vnl;

inversion_set_rec.et_inversion_tbl := inversion_tbl;
inversion_set_rec.et_subtotal_agrupado_rec := inv_subtotal_rec;

moneda_funcional_set_rec.et_moneda_funcional_tbl := moneda_funcional_tbl;
moneda_funcional_set_rec.et_subtotal_agrupado_rec := mf_subtotal_rec;

depreciacion_set_rec.et_depreciacion_tbl := depreciacion_tbl;
depreciacion_set_rec.et_subtotal_agrupado_rec := dpn_subtotal_rec;

tt_by_rubro_rec.et_inversion_set_rec := inversion_set_rec;
tt_by_rubro_rec.et_moneda_funcional_set_rec := moneda_funcional_set_rec;
tt_by_rubro_rec.et_depreciacion_set_rec := depreciacion_set_rec;
tt_by_rubro_rec.et_subtotal_vnl_rec := subtotal_vnl_rec;

pro_tt_by_rubro_rec := tt_by_rubro_rec;

END;


END XXGAM_SAF_RUBRO3_V2_PKG; 
/

