CREATE OR REPLACE package BODY APPS.XXGAM_SAF_EXE_ACUM_RUB6_PKG AS
 FUNCTION getPeriod(psi_periodoF in varchar2 ) 
 RETURN varchar2
 IS
 period varchar2(100);  /*ENE-17*/
 BEGIN
        period:='ENE-'||SUBSTR(psi_periodoF,5,2);
     return  period;
 EXCEPTION
WHEN OTHERS THEN
  return psi_periodoF;
 END;
 
 
 /*Imprimir structure*/
 procedure   print_op_men(pso_errmsg            out varchar2 
                         ,pso_errcod            out varchar2
                         ,psi_periodo          in  varchar2
                         ,pti_tt_by_rubro_rec   in  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec) is 
 
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
 
 ln_stop_step1     number := 1; 
 ln_stop_step2     number := 2;
 ln_stop_step3     number := 3;  
 ln_stop_step4     number := 4;  
 
    /**Auxiliares para insert a tabla temporal**/
   auXIdDpn varchar2(20);
   auXIdMf varchar2(20);
   auXIdInv varchar2(20);
   
   auXnumRubDpn varchar2(20);
   auXnumRubMf varchar2(20);
   auXnumRubInv varchar2(20);
   
   auXnameRubDpn varchar2(20);
   auXnameRubMf varchar2(20);
   auXnameRubInv varchar2(20);
   
   auxcuentaDpn varchar2(30);
   auxcuentaMf varchar2(30);
   auxcuentaInv varchar2(30);
   
   auxConceptoDpn varchar2(200);
   auxConceptoMf varchar2(200);
   auxConceptoInv varchar2(200);
   
   auxSaldoInicialDpn number;
   auxSaldoInicialMf number;
    auxSaldoInicialInv number;
    
    auxAltasInv number;
    auxAltasMf number;
    auxAltasDpn number;
    
    auxDismInv number;
    auxDismInvMf number;
    auxDismInvDpn number;
    
    auxTransInv number;
    auxTransMf number;
    auxTransDpn number;
    
    auxMoi_sin_ingrInv number;
    auxMoi_sin_ingrMf number;
    auxMoi_sin_ingrDpn number;
    
    auxMoi_x_vtaInv number;
    auxMoi_x_vtaMf number;
    auxMoi_x_vtaDpn number;
    
    auxDPN_sinIngrInv number;
    auxDPN_sinIngrMf number;
    auxDPN_sinIngrDpn number;
    
    auxDPN_x_vtaInv number;
    auxDPN_x_vtaMf number;
    auxDPN_x_vtaDpn number;
    
    auxDep_ej_Inv number;
    auxDep_ej_Mf number;
    auxDep_ej_Dpn number;
    
    
    auxSumaInv number;
    auxSumaMf number;
    auxSumaDpn number;
    
    auxSdoFinalInv number;
    auxSdoFinalMf number;
    auxSdoFinalDpn number;
                      
 begin 
 
 
  if 1 = ln_stop_step1 then 
  pso_errmsg := null; 
  pso_errcod := '0'; 
  
  fnd_file.put_line(fnd_file.log,'Comienza nuevo rubro'); 
  
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
  
  
  
 /** ENTER INVERSION **/
 
   if let_inversion_tbl.count >0 then 
 
   if 2 = ln_stop_step2 then 
 
  
   for idx in let_inversion_tbl.first .. let_inversion_tbl.last loop  
   
 
                    insert into XXGAM_SAF_ACUM_R12 (TIPO_ACUM
                                                   ,periodo,
                                                    NUM_RUBRO,
                                                    NAME_RUB,
                                                    CUENTA,
                                                    CONCEPTO,
                                                    SALDO_INICIAL,
                                                    ADICIONES,
                                                    DISMIN_INVER,
                                                    TRANSFERENCIA,
                                                    MOI_SIN_INGRESOS,
                                                    MOI_X_VENTA,
                                                    DPN_SIN_INGRESO,
                                                    DPN_X_VENTA,
                                                    DEPR_EJERCICIO,
                                                    SUMA,
                                                    SDO_FINAL)
                                                values('INVERSION',
                                                      psi_periodo,
                                                let_inversion_tbl(idx).num_rubro,
                                                let_inversion_tbl(idx).rubro,
                                                let_inversion_tbl(idx).cuenta||'-'||let_inversion_tbl(idx).subcuenta,
                                                let_inversion_tbl(idx).concepto,
                                                let_inversion_tbl(idx).saldo_inicial,
                                                let_inversion_tbl(idx).ad_altas,
                                                let_inversion_tbl(idx).ad_dism_inversa,
                                                let_inversion_tbl(idx).ad_transferencia,
                                                let_inversion_tbl(idx).ret_moi_sin_ingr,
                                                let_inversion_tbl(idx).ret_moi_x_venta,
                                                let_inversion_tbl(idx).ret_dpn_sin_ingr,
                                                let_inversion_tbl(idx).ret_dpn_x_venta,
                                                let_inversion_tbl(idx).depn_del_ejercicio,
                                                let_inversion_tbl(idx).suma,
                                                let_inversion_tbl(idx).saldo_final
                                                );

  end loop;
  

  
   end if; /** END  if 3 = ln_stop_step2 then  **/
  
  end if; /** END  if let_inversion_tbl.count >0 then  **/
  
  
   if let_moneda_funcional_tbl.count >0 then 
  
   if 3 = ln_stop_step3 then 
  
  
  
     for idx in let_moneda_funcional_tbl.first .. let_moneda_funcional_tbl.last loop  
   
                    insert into XXGAM_SAF_ACUM_R12 (TIPO_ACUM,
                                                    periodo,
                                                    NUM_RUBRO,
                                                    NAME_RUB,
                                                    CUENTA,
                                                    CONCEPTO,
                                                    SALDO_INICIAL,
                                                    ADICIONES,
                                                    DISMIN_INVER,
                                                    TRANSFERENCIA,
                                                    MOI_SIN_INGRESOS,
                                                    MOI_X_VENTA,
                                                    DPN_SIN_INGRESO,
                                                    DPN_X_VENTA,
                                                    DEPR_EJERCICIO,
                                                    SUMA,
                                                    SDO_FINAL,
                                                    MF_RESULTADOS,
                                                    MF_BALANCE)
                                                values('MF',
                                                psi_periodo,
                                                let_moneda_funcional_tbl(idx).num_rubro,
                                                let_moneda_funcional_tbl(idx).rubro,
                                                let_moneda_funcional_tbl(idx).cuenta||'-'||let_moneda_funcional_tbl(idx).subcuenta,
                                                let_moneda_funcional_tbl(idx).concepto,
                                                let_moneda_funcional_tbl(idx).saldo_inicial,
                                                let_moneda_funcional_tbl(idx).ad_altas,
                                                let_moneda_funcional_tbl(idx).ad_dism_inversa,
                                                let_moneda_funcional_tbl(idx).ad_transferencia,
                                                let_moneda_funcional_tbl(idx).ret_moi_sin_ingr,
                                                let_moneda_funcional_tbl(idx).ret_moi_x_venta,
                                                let_moneda_funcional_tbl(idx).ret_dpn_sin_ingr,
                                                let_moneda_funcional_tbl(idx).ret_dpn_x_venta,
                                                let_moneda_funcional_tbl(idx).depn_del_ejercicio,
                                                let_moneda_funcional_tbl(idx).suma,
                                                let_moneda_funcional_tbl(idx).saldo_final,
                                                let_moneda_funcional_tbl(idx).mf_resultados,
                                                let_moneda_funcional_tbl(idx).mf_balance
                                                );
   
   
  end loop;
  
  
   end if; /** END if 4 = ln_stop_step3 then  **/ 
  
  end if; /** END if let_moneda_funcional_tbl.count >0 then  **/
  
  
  /** ENTER DEPRECIACION **/
  
   fnd_file.put_line(fnd_file.log,'Count Dpn Table:'||let_depreciacion_tbl.count); 
   if let_depreciacion_tbl.count > 0 then  
   if 4 = ln_stop_step4 then 
 
   
   for idx in let_depreciacion_tbl.first .. let_depreciacion_tbl.last loop  
  
                    insert into XXGAM_SAF_ACUM_R12 (TIPO_ACUM,
                                                    periodo,
                                                    NUM_RUBRO,
                                                    NAME_RUB,
                                                    CUENTA,
                                                    CONCEPTO,
                                                    SALDO_INICIAL,
                                                    ADICIONES,
                                                    DISMIN_INVER,
                                                    TRANSFERENCIA,
                                                    MOI_SIN_INGRESOS,
                                                    MOI_X_VENTA,
                                                    DPN_SIN_INGRESO,
                                                    DPN_X_VENTA,
                                                    DEPR_EJERCICIO,
                                                    SUMA,
                                                    SDO_FINAL)
                                                values('DPN',
                                                psi_periodo,
                                                let_depreciacion_tbl(idx).num_rubro,
                                                let_depreciacion_tbl(idx).rubro,
                                                let_depreciacion_tbl(idx).cuenta||'-'||let_depreciacion_tbl(idx).subcuenta,
                                                let_depreciacion_tbl(idx).concepto,
                                                let_depreciacion_tbl(idx).saldo_inicial,
                                                let_depreciacion_tbl(idx).ad_altas,
                                                let_depreciacion_tbl(idx).ad_dism_inversa,
                                                let_depreciacion_tbl(idx).ad_transferencia,
                                                let_depreciacion_tbl(idx).ret_moi_sin_ingr,
                                                let_depreciacion_tbl(idx).ret_moi_x_venta,
                                                let_depreciacion_tbl(idx).ret_dpn_sin_ingr,
                                                let_depreciacion_tbl(idx).ret_dpn_x_venta,
                                                let_depreciacion_tbl(idx).depn_del_ejercicio,
                                                let_depreciacion_tbl(idx).suma,
                                                let_depreciacion_tbl(idx).saldo_final
                                                );
 
   
  end loop;
  
 
  
   end if; /** END   if 5 = ln_stop_step4 then  **/
  end if; /** END  if let_depreciacion_tbl.count > 0 then   **/
   
  
  
  
  end if; /** END if 2 = ln_stop_step1 then  **/
  
  
Exception 
            when  no_data_found then
                      pso_errmsg := 'Exception : no data found ' || sqlerrm || ',' ||sqlcode;
                     pso_errcod :='2';
                    
            WHEN too_many_rows then
                    pso_errmsg := 'Exception : toomanyrows ' || sqlerrm || ',' ||sqlcode;
                     pso_errcod :='2';
                
            WHEN COLLECTION_IS_NULL then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
                   
            WHEN INVALID_NUMBER then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
                   
            WHEN NOT_LOGGED_ON then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
                  
             when others then 
              fnd_file.put_line(fnd_file.log,'Exception print_op_men:'||sqlerrm||' ,'||sqlcode);
              
              pso_errmsg := 'Exception print_op_men:'||sqlerrm||' ,'||sqlcode; 
              pso_errcod := '2'; 
  
 end print_op_men; 
 
 





PROCEDURE execute_main_r6 (PSO_ERRMSG         out VARCHAR2
                          ,PSO_ERRCOD         out VARCHAR2
                          ,PSI_PERIODO        in VARCHAR2
                          ,PSI_OPERATING_UNIT in VARCHAR2
                          ,PSI_DIVISA         in VARCHAR2
                           )
   IS

   LR_TT_BY_RUBRO_REC         XXGAM_SAF_OP_MEN_PKG.T_BY_RUBRO_REC;
  
   
   BEGIN                /*copy_*/
    APPS.XXGAM_SAF_RUBRO6_PKG.EXECUTE_RUBRO ( PSO_ERRMSG          => PSO_ERRMSG       
                                             , PSO_ERRCOD          => PSO_ERRCOD
                                             , PSI_OPERATING_UNIT  => PSI_OPERATING_UNIT
                                             , PSI_PERIODO         => PSI_PERIODO
                                             , PSI_DIVISA          => PSI_DIVISA
                                             , PRO_TT_BY_RUBRO_REC => LR_TT_BY_RUBRO_REC
                                                 );
                                                 
          /*TODO: Recuperar la estructura de arriba e insertarla en la tabla_temporal*/                    
     
                XXGAM_SAF_EXE_ACUM_RUB6_PKG.print_op_men( PSO_ERRMSG          => PSO_ERRMSG 
                                                        , PSO_ERRCOD          => PSO_ERRCOD
                                                        , psi_periodo         => PSI_PERIODO
                                                        , pti_tt_by_rubro_rec => LR_TT_BY_RUBRO_REC
                                                        );

  
   EXCEPTION 
      WHEN OTHERS
      THEN
         RETURN;
   END execute_main_r6;
PROCEDURE execute_setAcumulado_r6 ( PSO_ERRMSG           out VARCHAR2
                                    ,PSO_ERRCOD           out VARCHAR2
                                    ,psi_periodo_ini      in  varchar2
                                    ,pro_tt_by_rubro_rec  out XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec
                                    )
IS
lri_tt_by_rubro_rec                    XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;     /*estructura*/
lt_inversion_tbl                  XXGAM_SAF_OP_MEN_PKG.t_inversion_tbl;    /*tabla*/
ltt_inversion_set_rec                XXGAM_SAF_OP_MEN_PKG.t_inversion_set_rec;  /*SET*/

lt_moneda_funcional_tbl XXGAM_SAF_OP_MEN_PKG.t_moneda_funcional_tbl;         /*Tabla*/
ltt_moneda_funcional_set_rec   XXGAM_SAF_OP_MEN_PKG.t_moneda_funcional_set_rec;

lt_depreciacion_tbl XXGAM_SAF_OP_MEN_PKG.t_depreciacion_tbl;     /**Tabla**/
ltt_depreciacion_set_rec XXGAM_SAF_OP_MEN_PKG.t_depreciacion_set_rec;

/* Subtotales VNL*/
   lt_subtotal_inversion_info_rec       XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de inversion
   lt_subtotal_mf_info_rec              XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de MF
   lt_subtotal_dpn_info_rec             XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de depreciación
   

lt_subtotal_vnl_info_rec             XXGAM_SAF_OP_MEN_PKG.t_subtotal_vnl_rec;

auxSInicial number :=0;
auxSInicial_mf number:=0;
auxSinicial_dpn number:=0;

auxAdic_inv number:=0;
auxAdic_mf number:=0;
auxAdic_dpn number:=0;

aux_dis_inversa_inv  number:=0;
aux_trasfer_inv      number:=0;
aux_moi_s_ingr_inv   number:=0;
aux_moi_x_vta_inv    number:=0;

aux_dis_inversa_mf  number:=0;
aux_trasfer_mf      number:=0;
aux_moi_s_ingr_mf   number:=0;
aux_moi_x_vta_mf    number:=0;          /*added*/

auxDep_Ej_inv number:=0;
auxDep_Ej_mf number:=0;
auxDep_Ej_dpn number:=0;

aux_sin_ingreso_dpn   number :=0; 
aux_x_venta_dpn       number :=0; 

auxSuma_inv number:=0;
auxSuma_mf number:=0;
auxSuma_dpn number:=0;

auxSdo_F_inv number:=0;
auxSdo_F_mf number:=0;
auxSdo_F_dpn number:=0;



aux_mf_resultados number :=0; 
aux_mf_balance    number :=0; 

/*Record Inversion*/
cursor get_agrupado_info
                    is 
                    /**Start Cursor**/
                   select distinct(cuenta),tipo_acum from XXGAM_SAF_ACUM_R12 where tipo_acum='INVERSION' order by tipo_acum,cuenta; 
                   agrupado_info_rec    get_agrupado_info%ROWTYPE;   
                   /**End Cursor**/  
/*Record Inversion*/
cursor get_agrupado_info_mf
                    is 
                    /**Start Cursor**/
                   select distinct(cuenta),tipo_acum from XXGAM_SAF_ACUM_R12 where tipo_acum='MF' order by tipo_acum,cuenta; 
                   agrupado_info_rec_mf    get_agrupado_info_mf%ROWTYPE;   
                   /**End Cursor**/  
cursor get_agrupado_info_dpn
                    is 
                    /**Start Cursor**/
                   select distinct(cuenta),tipo_acum from XXGAM_SAF_ACUM_R12 where tipo_acum='DPN' order by tipo_acum,cuenta; 
                   agrupado_info_rec_dpn    get_agrupado_info_dpn%ROWTYPE;   
                   /**End Cursor**/  
  Auxcount number:=1;                   
BEGIN






/*Inversion*/
open get_agrupado_info();
            loop
            fetch get_agrupado_info into agrupado_info_rec;
            exit when get_agrupado_info%notfound;
            if (agrupado_info_rec.tipo_acum='INVERSION')then
                null; 
            end if;
               
                              
                                
              select distinct(SUBSTR(CUENTA,1,4)) into lt_inversion_tbl(Auxcount).cuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select distinct(SUBSTR(CUENTA,6,5)) into lt_inversion_tbl(Auxcount).subcuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;    
              select distinct((NUM_RUBRO))  into lt_inversion_tbl(Auxcount).num_rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;  
              select distinct(NAME_RUB)  into lt_inversion_tbl(Auxcount).rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;  
              select distinct(CONCEPTO)  into lt_inversion_tbl(Auxcount).concepto from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              
              select sum(SALDO_INICIAL) 
                into lt_inversion_tbl(Auxcount).saldo_inicial 
                from XXGAM_SAF_ACUM_R12 
                where cuenta=agrupado_info_rec.cuenta
                and periodo = psi_periodo_ini
                ;
              
                                
              select sum(ADICIONES)into lt_inversion_tbl(Auxcount).ad_altas  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              
              select sum(DISMIN_INVER )into lt_inversion_tbl(Auxcount).ad_dism_inversa  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(TRANSFERENCIA)into lt_inversion_tbl(Auxcount).ad_transferencia  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(MOI_SIN_INGRESOS)into lt_inversion_tbl(Auxcount).ret_moi_sin_ingr  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(MOI_X_VENTA)into lt_inversion_tbl(Auxcount).ret_moi_x_venta  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              
              
              select sum(Depr_Ejercicio) into lt_inversion_tbl(Auxcount).depn_del_ejercicio  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(SUMA) into lt_inversion_tbl(Auxcount).suma from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              
              /** select sum(SDO_FINAL) into lt_inversion_tbl(Auxcount).saldo_final  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta; **/
              
              lt_inversion_tbl(Auxcount).saldo_final := lt_inversion_tbl(Auxcount).saldo_inicial + lt_inversion_tbl(Auxcount).suma; 

               auxSInicial:=nvl(auxSInicial,0) +  nvl(lt_inversion_tbl(Auxcount).saldo_inicial,0);
               auxAdic_inv:=nvl(auxAdic_inv,0) +  nvl(lt_inversion_tbl(Auxcount).ad_altas,0);
               auxDep_Ej_inv:=nvl(auxDep_Ej_inv,0) +  nvl(lt_inversion_tbl(Auxcount).depn_del_ejercicio,0);
               auxSuma_inv:=nvl(auxSuma_inv,0) +  nvl(lt_inversion_tbl(Auxcount).suma,0);
               auxSdo_F_inv:=nvl(auxSdo_F_inv,0) +  nvl(lt_inversion_tbl(Auxcount).saldo_final,0);
               
               aux_dis_inversa_inv := nvl(aux_dis_inversa_inv,0) + nvl(lt_inversion_tbl(Auxcount).ad_dism_inversa,0); 
               aux_trasfer_inv := nvl(aux_trasfer_inv,0) + nvl(lt_inversion_tbl(Auxcount).ad_transferencia,0);
               aux_moi_s_ingr_inv := nvl(aux_moi_s_ingr_inv,0) + nvl(lt_inversion_tbl(Auxcount).ret_moi_sin_ingr,0);
               aux_moi_x_vta_inv := nvl(aux_moi_x_vta_inv,0) + nvl(lt_inversion_tbl(Auxcount).ret_moi_x_venta,0);
               
               Auxcount:=Auxcount+1;
               
             end loop;        --first , last
              --dbms_output.put_line('-----------> Row Count:'||lt_inversion_tbl%rowcount);
         close get_agrupado_info;  
        
          lt_subtotal_inversion_info_rec.agrupado :='INVERSION';
          lt_subtotal_inversion_info_rec.saldo_inicial:=auxSInicial;
          lt_subtotal_inversion_info_rec.ad_altas:=auxAdic_inv;
          
          lt_subtotal_inversion_info_rec.ad_dism_inversa:=aux_dis_inversa_inv;
          lt_subtotal_inversion_info_rec.ad_transferencia:=aux_trasfer_inv;
          lt_subtotal_inversion_info_rec.ret_moi_sin_ingr:=aux_moi_s_ingr_inv;
          lt_subtotal_inversion_info_rec.ret_moi_x_venta:=aux_moi_x_vta_inv;
          
          lt_subtotal_inversion_info_rec.depn_del_ejercicio:=auxAdic_inv;
          
          lt_subtotal_inversion_info_rec.depn_del_ejercicio:= auxDep_Ej_inv;
          lt_subtotal_inversion_info_rec.suma:= auxSuma_inv;
          lt_subtotal_inversion_info_rec.saldo_final:=auxSdo_F_inv;

          
 
         Auxcount:=1;
         /*Moneda Funcional*/
         open get_agrupado_info_mf();
            loop
            fetch get_agrupado_info_mf into agrupado_info_rec_mf;
            exit when get_agrupado_info_mf%notfound;
            if (agrupado_info_rec_mf.tipo_acum='MF')then
                dbms_output.put_line('MF: ');
            end if;
               dbms_output.put_line(agrupado_info_rec_mf.cuenta);
                dbms_output.put_line('AuxC: '||Auxcount);
                 select distinct(SUBSTR(CUENTA,1,4))  into lt_moneda_funcional_tbl(Auxcount).cuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
                  select distinct(SUBSTR(CUENTA,6,5))  into lt_moneda_funcional_tbl(Auxcount).subcuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
               select distinct(NUM_RUBRO)  into lt_moneda_funcional_tbl(Auxcount).num_rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
                select distinct(NAME_RUB)  into lt_moneda_funcional_tbl(Auxcount).rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select distinct(CONCEPTO)  into lt_moneda_funcional_tbl(Auxcount).concepto from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              
              select sum(SALDO_INICIAL) 
                into lt_moneda_funcional_tbl(Auxcount).saldo_inicial 
                from XXGAM_SAF_ACUM_R12
                 where cuenta=agrupado_info_rec_mf.cuenta
                 and periodo = psi_periodo_ini
                 ;
              
              select sum(ADICIONES)into lt_moneda_funcional_tbl(Auxcount).ad_altas  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(Depr_Ejercicio) into lt_moneda_funcional_tbl(Auxcount).depn_del_ejercicio  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(SUMA) into lt_moneda_funcional_tbl(Auxcount).suma from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(SDO_FINAL) into lt_moneda_funcional_tbl(Auxcount).saldo_final  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              dbms_output.put_line('Saldo inicial: '||lt_moneda_funcional_tbl(Auxcount).saldo_inicial || ' Adiciones: '||lt_moneda_funcional_tbl(Auxcount).ad_altas||' Dpn Ejercicio:  '|| lt_moneda_funcional_tbl(Auxcount).depn_del_ejercicio|| ' Suma: '||lt_moneda_funcional_tbl(Auxcount).suma||' Sdo Final : '||lt_moneda_funcional_tbl(Auxcount).saldo_final);
            
              select sum(MF_RESULTADOS) into lt_moneda_funcional_tbl(Auxcount).mf_resultados  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(MF_BALANCE) into lt_moneda_funcional_tbl(Auxcount).mf_balance  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
            
            
              auxSInicial_mf:=nvl(auxSInicial_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).saldo_inicial,0);
              auxAdic_mf:=nvl(auxAdic_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).ad_altas,0);
              auxDep_Ej_mf:=nvl(auxDep_Ej_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).depn_del_ejercicio,0);
              auxSuma_mf:=nvl(auxSuma_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).suma,0);
              auxSdo_F_mf:=nvl(auxSdo_F_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).saldo_final,0);
              
              aux_dis_inversa_mf := nvl(aux_dis_inversa_mf,0) + nvl(lt_moneda_funcional_tbl(Auxcount).ad_dism_inversa,0); 
              aux_trasfer_mf := nvl(aux_dis_inversa_mf,0) + nvl(lt_moneda_funcional_tbl(Auxcount).ad_transferencia,0);
              aux_moi_s_ingr_mf := nvl(aux_dis_inversa_mf,0) + nvl(lt_moneda_funcional_tbl(Auxcount).ret_moi_sin_ingr,0);
              aux_moi_x_vta_mf := nvl(aux_dis_inversa_mf,0) + nvl(lt_moneda_funcional_tbl(Auxcount).ret_moi_x_venta,0);
              
              aux_mf_resultados := nvl(aux_mf_resultados,0) + nvl(lt_moneda_funcional_tbl(Auxcount).mf_resultados,0);
              aux_mf_balance := nvl(aux_mf_balance,0) + nvl(lt_moneda_funcional_tbl(Auxcount).mf_balance,0);
              
               Auxcount:=Auxcount+1;
             end loop;        
              dbms_output.put_line('-----------> Row Count:'||get_agrupado_info_mf%rowcount);
         close get_agrupado_info_mf;  
         /*subtotales*/
         lt_subtotal_mf_info_rec.agrupado:='MF';
         lt_subtotal_mf_info_rec.saldo_inicial:=auxSInicial_mf;
          lt_subtotal_mf_info_rec.ad_altas:=auxAdic_mf;
          lt_subtotal_mf_info_rec.depn_del_ejercicio:=auxDep_Ej_mf;
         lt_subtotal_mf_info_rec.suma:= auxSuma_mf;
         lt_subtotal_mf_info_rec.saldo_final:=auxSdo_F_mf;
         lt_subtotal_mf_info_rec.mf_resultados := aux_mf_resultados; 
         lt_subtotal_mf_info_rec.mf_balance    := aux_mf_balance; 
         
         
         
         
         Auxcount:=1;
         /*Depreciacion*/
         open get_agrupado_info_dpn();
            loop
            fetch get_agrupado_info_dpn into agrupado_info_rec_dpn;
            exit when get_agrupado_info_dpn%notfound;
            if (agrupado_info_rec_dpn.tipo_acum='DPN')then
                dbms_output.put_line('DPN: ');
            end if;
               dbms_output.put_line(agrupado_info_rec_dpn.cuenta);
                dbms_output.put_line('AuxC: '||Auxcount);
               
               -- select sum(SALDO_INICIAL) into v1257_16001_Sin_inv from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
               --dbms_output.put_line('sdo_inicial: '|| v1257_16001_Sin_inv); 
               select distinct(SUBSTR(CUENTA,1,4)) into lt_depreciacion_tbl(Auxcount).cuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta; 
               select distinct(SUBSTR(CUENTA,6,5)) into lt_depreciacion_tbl(Auxcount).subcuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta; 
              select distinct(NUM_RUBRO)  into lt_depreciacion_tbl(Auxcount).num_rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta; 
              select distinct(NAME_RUB)  into lt_depreciacion_tbl(Auxcount).rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta; 
              select distinct(CONCEPTO)  into lt_depreciacion_tbl(Auxcount).concepto from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta; 
              
              select sum(SALDO_INICIAL)
               into lt_depreciacion_tbl(Auxcount).saldo_inicial 
               from XXGAM_SAF_ACUM_R12 
              where cuenta=agrupado_info_rec_dpn.cuenta
                and periodo = psi_periodo_ini
                 ;
              
              select sum(ADICIONES)into lt_depreciacion_tbl(Auxcount).ad_altas  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(Depr_Ejercicio) into lt_depreciacion_tbl(Auxcount).depn_del_ejercicio  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(SUMA) into lt_depreciacion_tbl(Auxcount).suma from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(SDO_FINAL) into lt_depreciacion_tbl(Auxcount).saldo_final  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              
              select sum(DPN_SIN_INGRESO) into lt_depreciacion_tbl(Auxcount).ret_dpn_sin_ingr from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(DPN_X_VENTA) into lt_depreciacion_tbl(Auxcount).ret_dpn_x_venta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              
              dbms_output.put_line('Saldo inicial: '||lt_depreciacion_tbl(Auxcount).saldo_inicial || ' Adiciones: '||lt_depreciacion_tbl(Auxcount).ad_altas||' Dpn Ejercicio:  '|| lt_depreciacion_tbl(Auxcount).depn_del_ejercicio|| ' Suma: '||lt_depreciacion_tbl(Auxcount).suma||' Sdo Final : '||lt_depreciacion_tbl(Auxcount).saldo_final);
              auxSinicial_dpn:=nvl(auxSinicial_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).saldo_inicial,0);
              auxAdic_dpn:=nvl(auxAdic_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).ad_altas,0);
              
              aux_sin_ingreso_dpn := nvl(aux_sin_ingreso_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).ret_dpn_sin_ingr,0); 
              aux_x_venta_dpn := nvl(aux_sin_ingreso_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).ret_dpn_x_venta,0);
              
              auxDep_Ej_dpn:=nvl(auxDep_Ej_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).depn_del_ejercicio,0);
              auxSuma_dpn:=nvl(auxSuma_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).suma,0);
              auxSdo_F_dpn:=nvl(auxSdo_F_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).saldo_final,0);
              
               Auxcount:=Auxcount+1;
             end loop;        
              dbms_output.put_line('-----------> Row Count:'||get_agrupado_info_dpn%rowcount);
         close get_agrupado_info_dpn; 
         lt_subtotal_dpn_info_rec.agrupado:='DPN';
          lt_subtotal_dpn_info_rec.saldo_inicial:=auxSinicial_dpn;
          
          lt_subtotal_dpn_info_rec.ret_dpn_sin_ingr := nvl(aux_sin_ingreso_dpn,0); 
          lt_subtotal_dpn_info_rec.ret_dpn_x_venta  := nvl(aux_x_venta_dpn,0); 
          
          lt_subtotal_dpn_info_rec.depn_del_ejercicio:=auxDep_Ej_dpn;
           lt_subtotal_dpn_info_rec.suma:=auxSuma_dpn;
           lt_subtotal_dpn_info_rec.saldo_final:=auxSdo_F_dpn;
          
          /*VNL*/
          lt_subtotal_vnl_info_rec.saldo_inicial:=auxSinicial_dpn+auxSInicial_mf+auxSInicial;
          lt_subtotal_vnl_info_rec.ad_altas:=auxAdic_inv+auxAdic_mf +auxAdic_dpn;
          
          lt_subtotal_vnl_info_rec.ret_moi_sin_ingr :=nvl(lt_subtotal_inversion_info_rec.ret_moi_sin_ingr,0) +nvl(null,0) +nvl(null,0);  
          lt_subtotal_vnl_info_rec.ret_moi_x_venta  :=nvl(lt_subtotal_inversion_info_rec.ret_moi_x_venta,0) +nvl(null,0) +nvl(null,0);
          lt_subtotal_vnl_info_rec.ret_dpn_sin_ingr :=nvl(null,0) +nvl(null,0) +nvl(lt_subtotal_dpn_info_rec.ret_dpn_sin_ingr ,0);
          lt_subtotal_vnl_info_rec.ret_dpn_x_venta  :=nvl(null,0) +nvl(null,0) +nvl(lt_subtotal_dpn_info_rec.ret_dpn_x_venta,0);
          
          lt_subtotal_vnl_info_rec.depn_del_ejercicio:=auxDep_Ej_inv + auxDep_Ej_mf  + auxDep_Ej_dpn ;
          lt_subtotal_vnl_info_rec.suma:=auxSuma_inv +auxSuma_mf  +auxSuma_dpn;
          lt_subtotal_vnl_info_rec.saldo_final:=auxSdo_F_inv+auxSdo_F_mf +auxSdo_F_dpn;
         
         /*Seteo de el struct*/
          ltt_depreciacion_set_rec.et_depreciacion_tbl := lt_depreciacion_tbl;
          /*subtotals*/
         ltt_depreciacion_set_rec.et_subtotal_agrupado_rec := lt_subtotal_dpn_info_rec;
         
         ltt_moneda_funcional_set_rec.et_moneda_funcional_tbl := lt_moneda_funcional_tbl;
            ltt_moneda_funcional_set_rec.et_subtotal_agrupado_rec :=lt_subtotal_mf_info_rec;
           
           ltt_inversion_set_rec.et_inversion_tbl := lt_inversion_tbl;
        ltt_inversion_set_rec.et_subtotal_agrupado_rec := lt_subtotal_inversion_info_rec;
         
         /*Seteo de estructuras*/
         lri_tt_by_rubro_rec.et_inversion_set_rec := ltt_inversion_set_rec;
         
         lri_tt_by_rubro_rec.et_moneda_funcional_set_rec := ltt_moneda_funcional_set_rec;
         
         lri_tt_by_rubro_rec.et_depreciacion_set_rec := ltt_depreciacion_set_rec;
         
         lri_tt_by_rubro_rec.et_subtotal_vnl_rec := lt_subtotal_vnl_info_rec;
         
         pro_tt_by_rubro_rec:=lri_tt_by_rubro_rec;
         
         Exception 
            when  no_data_found then
                      pso_errmsg := 'Exception : no data found ' || sqlerrm || ',' ||sqlcode;
                     pso_errcod :='2';
                      
            WHEN too_many_rows then
                    pso_errmsg := 'Exception : toomanyrows ' || sqlerrm || ',' ||sqlcode;
                     pso_errcod :='2';
            WHEN COLLECTION_IS_NULL then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
            WHEN INVALID_NUMBER then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
            WHEN NOT_LOGGED_ON then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
                 WHEN OTHERS then
                    pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
                    
END;

procedure main (pso_errmsg           out varchar2
              , pso_errcod           out varchar2
              ,  psi_operating_unit  in  VARCHAR2
              ,  psi_periodo_final   in  varchar2
              ,  psi_divisa          in  varchar2
              ,  pro_tt_by_rubro_rec out XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec
               ) 
is


 cursor get_agrupado_info(psi_periodo_final varchar2 )
                    is 
                    /*Obtenemos los periodos*/
                    /**Start Cursor**/
                    SELECT PERIOD_NAME  
                    FROM GL_PERIODS               
                    WHERE START_DATE BETWEEN (SELECT START_DATE  
                                                FROM GL_PERIODS  
                                               WHERE PERIOD_NAME = getPeriod(psi_periodo_final)  
                                                 AND UPPER(PERIOD_TYPE) = 'MONTH'
                                              )
                    AND (SELECT END_DATE  
                            FROM GL_PERIODS 
                           WHERE PERIOD_NAME = psi_periodo_final  
                             AND UPPER(PERIOD_TYPE) = 'MONTH' 
                         )   
                   AND UPPER(PERIOD_TYPE) = 'MONTH';
                   
agrupado_info_rec    get_agrupado_info%ROWTYPE;   
/**End Cursor**/
ls_errmsg            varchar2(2000);
ls_errcod            varchar2(2000);
auxContador          number;
LPRO_TT_BY_RUBRO_REC XXGAM_SAF_OP_MEN_PKG.T_BY_RUBRO_REC;
lt_inversion_tbl                  XXGAM_SAF_OP_MEN_PKG.t_inversion_tbl;    /*tabla*/
ltt_inversion_set_rec                XXGAM_SAF_OP_MEN_PKG.t_inversion_set_rec;  /*SET*/

ls_periodo_inicial    varchar2(200);                    

le_main               exception; 

begin 

 ls_periodo_inicial := null;             

    Fnd_file.put_line(Fnd_file.log, 'Comienza ENA main log'); 
  
  ls_periodo_inicial := 'ENE-'||substr(psi_periodo_final,5,2);     
      
   Fnd_file.put_line(Fnd_file.log, 'ls_periodo_inicial:'||ls_periodo_inicial); 

         open get_agrupado_info(psi_periodo_final );
        loop
        fetch get_agrupado_info into agrupado_info_rec;
        exit when get_agrupado_info%notfound;
            
          Fnd_file.put_line(Fnd_file.log,'Ejecutar execute_main_r6: '||agrupado_info_rec.PERIOD_NAME);
        /**Ejecutamos n veces el procedure r6 que inserta en la #tabla**/
         
           XXGAM_SAF_EXE_ACUM_RUB6_PKG.execute_main_r6( PSO_ERRMSG         => ls_errmsg
                                                         ,PSO_ERRCOD         => ls_errcod
                                                         ,PSI_PERIODO        => agrupado_info_rec.PERIOD_NAME
                                                         ,PSI_OPERATING_UNIT => psi_operating_unit  
                                                         ,PSI_DIVISA         => psi_divisa
                                                         );
           Fnd_file.put_line(Fnd_file.log,'Ejecutar execute_main_r6');
         end loop;        
           Fnd_file.put_line(Fnd_file.log,'----------> Row Count:'||get_agrupado_info%rowcount);
         close get_agrupado_info;   
        
        Fnd_file.put_line(Fnd_file.log,'ejecutando acumulado...');
     
      
        XXGAM_SAF_EXE_ACUM_RUB6_PKG.execute_setAcumulado_r6( PSO_ERRMSG         => ls_errmsg
                                                            ,PSO_ERRCOD         => ls_errcod
                                                            ,psi_periodo_ini    => ls_periodo_inicial
                                                            ,PRO_TT_BY_RUBRO_REC => LPRO_TT_BY_RUBRO_REC 
                                                            );
                                                
        if   ls_errmsg is not null then 
        
          raise le_main; 
        
        end if;                                             
     
        pro_tt_by_rubro_rec:= LPRO_TT_BY_RUBRO_REC;
        commit;
        
     
     
        ltt_inversion_set_rec:=LPRO_TT_BY_RUBRO_REC.et_inversion_set_rec;
        lt_inversion_tbl:=ltt_inversion_set_rec.et_inversion_tbl;
        Fnd_file.put_line(Fnd_file.log, 'Finaliza ENA main log');
        
        Exception when le_main then 
        
             pso_errmsg :=    ls_errmsg; 
             rollback;  
        
            when  no_data_found then
                      pso_errmsg := 'Exception : no data found ' || sqlerrm || ',' ||sqlcode;
                     pso_errcod :='2';
            rollback;  
            WHEN too_many_rows then
                    pso_errmsg := 'Exception : toomanyrows ' || sqlerrm || ',' ||sqlcode;
                     pso_errcod :='2';
              rollback;  
            WHEN COLLECTION_IS_NULL then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
      
             rollback;           
            WHEN INVALID_NUMBER then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
      
                  rollback;    
            WHEN NOT_LOGGED_ON then
                     pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
      
                    rollback;  
                 WHEN OTHERS then
                    pso_errmsg := 'Exception: ' || sqlerrm || ',' ||sqlcode;
                    pso_errcod :='2';
                    rollback;  
                     
            end main;
            
END  XXGAM_SAF_EXE_ACUM_RUB6_PKG; 
/

