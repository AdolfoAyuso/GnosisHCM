CREATE OR REPLACE package BODY APPS.XXGAM_SAF_EXE_ACUM_RUB12_PKG AS
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
--   fnd_file.put_line(fnd_file.output,'<RUBRO>');



   for idx in let_inversion_tbl.first .. let_inversion_tbl.last loop


               auXIdInv:='INVERSION';
               auXnumRubInv      := let_inversion_tbl(idx).num_rubro;
            auXnameRubInv     := let_inversion_tbl(idx).rubro;
              auxcuentaInv      := let_inversion_tbl(idx).cuenta||'-'||let_inversion_tbl(idx).subcuenta;
             auxConceptoInv    := let_inversion_tbl(idx).concepto;
               auxSaldoInicialInv:= let_inversion_tbl(idx).saldo_inicial;
              auxAltasInv       := let_inversion_tbl(idx).ad_altas;
               auxDismInv        := let_inversion_tbl(idx).ad_dism_inversa;
              auxTransInv       := let_inversion_tbl(idx).ad_transferencia;
              auxMoi_sin_ingrInv:= let_inversion_tbl(idx).ret_moi_sin_ingr;
              auxMoi_x_vtaInv:=let_inversion_tbl(idx).ret_moi_x_venta;
              auxDPN_sinIngrInv:=let_inversion_tbl(idx).ret_dpn_sin_ingr;
              auxDPN_x_vtaInv:=let_inversion_tbl(idx).ret_dpn_x_venta;
              auxDep_ej_Inv:=let_inversion_tbl(idx).depn_del_ejercicio;
               auxSumaInv        := let_inversion_tbl(idx).suma;
              auxSdoFinalInv    := let_inversion_tbl(idx).saldo_final;

 insert into XXGAM_SAF_ACUM_R12 (periodo,
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
                                                values(auXIdInv,
                                                auXnumRubInv,
                                                auXnameRubInv,
                                                auxcuentaInv,
                                                auxConceptoInv,
                                                auxSaldoInicialInv,
                                                auxAltasInv,
                                                auxDismInv,
                                                auxTransInv,
                                                auxMoi_sin_ingrInv,
                                                auxMoi_x_vtaInv,
                                                auxDPN_sinIngrInv,
                                                auxDPN_x_vtaInv,
                                                auxDep_ej_Inv,
                                                auxSumaInv,
                                                auxSdoFinalInv
                                                );



  end loop;



   end if; /** END  if 3 = ln_stop_step2 then  **/

  end if; /** END  if let_inversion_tbl.count >0 then  **/


   if let_moneda_funcional_tbl.count >0 then

   if 3 = ln_stop_step3 then

  --fnd_file.put_line(fnd_file.output,'<RUBRO>');


  --ENTER MONEDA FUNCIONAL

  for idx in let_moneda_funcional_tbl.first .. let_moneda_funcional_tbl.last loop


     /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
   /*Llenado moneda funcional temporal*/
                auXIdMf:='MF';
         auXnumRubMf      := let_moneda_funcional_tbl(idx).num_rubro;
            auXnameRubMf     := let_moneda_funcional_tbl(idx).rubro;
            auxcuentaMf     := let_moneda_funcional_tbl(idx).cuenta||'-'||let_moneda_funcional_tbl(idx).subcuenta;
             auxConceptoMf    := let_moneda_funcional_tbl(idx).concepto;
              auxSaldoInicialMf:= let_moneda_funcional_tbl(idx).saldo_inicial;
              auxAltasMf       := let_moneda_funcional_tbl(idx).ad_altas;
             auxDismInvMf        := let_moneda_funcional_tbl(idx).ad_dism_inversa;
            auxTransMf       := let_moneda_funcional_tbl(idx).ad_transferencia;
              auxMoi_sin_ingrMf:= let_moneda_funcional_tbl(idx).ret_moi_sin_ingr;
              auxMoi_x_vtaMf:=let_moneda_funcional_tbl(idx).ret_moi_x_venta;
              auxDPN_sinIngrMf:=let_moneda_funcional_tbl(idx).ret_dpn_sin_ingr;
              auxDPN_x_vtaMf:=let_moneda_funcional_tbl(idx).ret_dpn_x_venta;
              auxDep_ej_Mf:=let_moneda_funcional_tbl(idx).depn_del_ejercicio;
              auxSumaMf        := let_moneda_funcional_tbl(idx).suma;
              auxSdoFinalMf    := let_moneda_funcional_tbl(idx).saldo_final;


 insert into XXGAM_SAF_ACUM_R12 (periodo,
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
                                                    mf_resultados,
                                                    mf_balance
                                                    )
                                                values(auXIdMf,
                                                auXnumRubMf,
                                                auXnameRubMf,
                                                auxcuentaMf,
                                                auxConceptoMf,
                                                auxSaldoInicialMf,
                                                auxAltasMf,
                                                auxDismInvMf,
                                                auxTransMf,
                                                auxMoi_sin_ingrMf,
                                                auxMoi_x_vtaMf,
                                                auxDPN_sinIngrMf,
                                                auxDPN_x_vtaMf,
                                                auxDep_ej_Mf,
                                                auxSumaMf,
                                                auxSdoFinalMf,
                                                let_moneda_funcional_tbl(idx).mf_resultados,
                                                let_moneda_funcional_tbl(idx).mf_balance
                                                );





  end loop;


   /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/

  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/




   end if; /** END if 4 = ln_stop_step3 then  **/

  end if; /** END if let_moneda_funcional_tbl.count >0 then  **/


  /** ENTER DEPRECIACION **/

   fnd_file.put_line(fnd_file.log,'Count Dpn Table:'||let_depreciacion_tbl.count);
   if let_depreciacion_tbl.count > 0 then
   if 4 = ln_stop_step4 then

   --fnd_file.put_line(fnd_file.output,'<RUBRO>');

  for idx in let_depreciacion_tbl.first .. let_depreciacion_tbl.last loop

   /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
     /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/







   /** Se agregarn en un futuro no lejano **/

   /*Llenado moneda funcional temporal*/
                auXIdDpn:='DPN';
         auXnumRubDpn      := let_depreciacion_tbl(idx).num_rubro;
            auXnameRubDpn     := let_depreciacion_tbl(idx).rubro;
            auxcuentaDpn     := let_depreciacion_tbl(idx).cuenta||'-'||let_depreciacion_tbl(idx).subcuenta;
             auxConceptoDpn    := let_depreciacion_tbl(idx).concepto;
              auxSaldoInicialDpn:= let_depreciacion_tbl(idx).saldo_inicial;
              auxAltasDpn       := let_depreciacion_tbl(idx).ad_altas;
             auxDismInvDpn        := let_depreciacion_tbl(idx).ad_dism_inversa;
            auxTransDpn       := let_depreciacion_tbl(idx).ad_transferencia;
              auxMoi_sin_ingrDpn:= let_depreciacion_tbl(idx).ret_moi_sin_ingr;
              auxMoi_x_vtaDpn:=let_depreciacion_tbl(idx).ret_moi_x_venta;
              auxDPN_sinIngrDpn:=let_depreciacion_tbl(idx).ret_dpn_sin_ingr;
              auxDPN_x_vtaDpn:=let_depreciacion_tbl(idx).ret_dpn_x_venta;
              auxDep_ej_Dpn:=let_depreciacion_tbl(idx).depn_del_ejercicio;
              auxSumaDpn        := let_depreciacion_tbl(idx).suma;
              auxSdoFinalDpn    := let_depreciacion_tbl(idx).saldo_final;


 insert into XXGAM_SAF_ACUM_R12 (periodo,
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
                                                values(auXIdDpn,
                                                auXnumRubDpn,
                                                auXnameRubDpn,
                                                auxcuentaDpn,
                                                auxConceptoDpn,
                                                auxSaldoInicialDpn,
                                                auxAltasDpn,
                                                auxDismInvDpn,
                                                auxTransDpn,
                                                auxMoi_sin_ingrDpn,
                                                auxMoi_x_vtaDpn,
                                                auxDPN_sinIngrDpn,
                                                auxDPN_x_vtaDpn,
                                                auxDep_ej_Dpn,
                                                auxSumaDpn,
                                                auxSdoFinalDpn
                                                );









  end loop;






  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/





   end if; /** END   if 5 = ln_stop_step4 then  **/
  end if; /** END  if let_depreciacion_tbl.count > 0 then   **/



    /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/






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







PROCEDURE execute_main_r12 (PSO_ERRMSG out VARCHAR2
                           ,PSO_ERRCOD out VARCHAR2
                           ,PSI_PERIODO in VARCHAR2
                           ,PSI_OPERATING_UNIT in VARCHAR2
                           , PSI_DIVISA in VARCHAR2)
   IS

   LR_TT_BY_RUBRO_REC         XXGAM_SAF_OP_MEN_PKG.T_BY_RUBRO_REC;


   BEGIN                /*copy_*/
    APPS.XXGAM_SAF_RUBRO12_PKG.EXECUTE_RUBRO ( PSO_ERRMSG          => PSO_ERRMSG
                                                  , PSO_ERRCOD          => PSO_ERRCOD
                                                  , PSI_OPERATING_UNIT  => PSI_OPERATING_UNIT
                                                  , PSI_PERIODO         => PSI_PERIODO
                                                  , PSI_DIVISA          => PSI_DIVISA
                                                  , PRO_TT_BY_RUBRO_REC => LR_TT_BY_RUBRO_REC
                                                 );
          /*TODO: Recuperar la estructura de arriba e insertarla en la tabla_temporal*/

                XXGAM_SAF_EXE_ACUM_RUB12_PKG .print_op_men( PSO_ERRMSG     =>       PSO_ERRMSG
                         ,PSO_ERRCOD          => PSO_ERRCOD
                         ,pti_tt_by_rubro_rec => LR_TT_BY_RUBRO_REC);


   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN;
   END execute_main_r12;
PROCEDURE execute_setAcumulado_r12 ( PSO_ERRMSG           out VARCHAR2
                                    ,PSO_ERRCOD           out VARCHAR2
                                    ,pro_tt_by_rubro_rec  out XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec
                                    )
IS

/*Record Inversion*/
cursor get_agrupado_info
                    is
                    /**Start Cursor**/
                   select distinct(cuenta),periodo from XXGAM_SAF_ACUM_R12 where periodo='INVERSION' order by periodo,cuenta;
                   agrupado_info_rec    get_agrupado_info%ROWTYPE;
                   /**End Cursor**/
/*Record Inversion*/
cursor get_agrupado_info_mf
                    is
                    /**Start Cursor**/
                   select distinct(cuenta),periodo from XXGAM_SAF_ACUM_R12 where periodo='MF' order by periodo,cuenta;
                   agrupado_info_rec_mf    get_agrupado_info_mf%ROWTYPE;
                   /**End Cursor**/
cursor get_agrupado_info_dpn
                    is
                    /**Start Cursor**/
                   select distinct(cuenta),periodo from XXGAM_SAF_ACUM_R12 where periodo='DPN' order by periodo,cuenta;
                   agrupado_info_rec_dpn    get_agrupado_info_dpn%ROWTYPE;
                   /**End Cursor**/



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
   lt_subtotal_dpn_info_rec             XXGAM_SAF_OP_MEN_PKG.t_subtotal_agrupado_rec;---variable record para subtotales de depreciacion


lt_subtotal_vnl_info_rec             XXGAM_SAF_OP_MEN_PKG.t_subtotal_vnl_rec;

auxSInicial number;
auxSInicial_mf number;
auxSinicial_dpn number;

auxAdic_inv number;
auxAdic_mf number;
auxAdic_dpn number;

auxDep_Ej_inv number;
auxDep_Ej_mf number;
auxDep_Ej_dpn number;

auxSuma_inv number;
auxSuma_mf number;
auxSuma_dpn number;

auxSdo_F_inv number;
auxSdo_F_mf number;
auxSdo_F_dpn number;

Auxcount number:=1;

aux_mf_resultados number :=0; 
aux_mf_balance    number :=0; 
  
  
BEGIN

/*Inversion*/
open get_agrupado_info();
            loop
            fetch get_agrupado_info into agrupado_info_rec;
            exit when get_agrupado_info%notfound;


              select distinct(SUBSTR(CUENTA,1,4)) into lt_inversion_tbl(Auxcount).cuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select distinct(SUBSTR(CUENTA,6,5)) into lt_inversion_tbl(Auxcount).subcuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select distinct((NUM_RUBRO))  into lt_inversion_tbl(Auxcount).num_rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select distinct(NAME_RUB)  into lt_inversion_tbl(Auxcount).rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select distinct(CONCEPTO)  into lt_inversion_tbl(Auxcount).concepto from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(SALDO_INICIAL) into lt_inversion_tbl(Auxcount).saldo_inicial from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(ADICIONES)into lt_inversion_tbl(Auxcount).ad_altas  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(Depr_Ejercicio) into lt_inversion_tbl(Auxcount).depn_del_ejercicio  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(SUMA) into lt_inversion_tbl(Auxcount).suma from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;
              select sum(SDO_FINAL) into lt_inversion_tbl(Auxcount).saldo_final  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec.cuenta;


               auxSInicial:=nvl(auxSInicial,0) +  nvl(lt_inversion_tbl(Auxcount).saldo_inicial,0);
               auxAdic_inv:=nvl(auxAdic_inv,0) +  nvl(lt_inversion_tbl(Auxcount).ad_altas,0);
               auxDep_Ej_inv:=nvl(auxDep_Ej_inv,0) +  nvl(lt_inversion_tbl(Auxcount).depn_del_ejercicio,0);
               auxSuma_inv:=nvl(auxSuma_inv,0) +  nvl(lt_inversion_tbl(Auxcount).suma,0);
               auxSdo_F_inv:=nvl(auxSdo_F_inv,0) +  nvl(lt_inversion_tbl(Auxcount).saldo_final,0);

               Auxcount:=Auxcount+1;

             end loop;        --first , last
              --dbms_output.put_line('-----------> Row Count:'||lt_inversion_tbl%rowcount);
         close get_agrupado_info;
         lt_subtotal_inversion_info_rec.agrupado :='INVERSION';
          lt_subtotal_inversion_info_rec.saldo_inicial:=auxSInicial;
            lt_subtotal_inversion_info_rec.ad_altas:=auxAdic_inv;
             lt_subtotal_inversion_info_rec.depn_del_ejercicio:= auxDep_Ej_inv;
            lt_subtotal_inversion_info_rec.suma:= auxSuma_inv;
            lt_subtotal_inversion_info_rec.saldo_final:=auxSdo_F_inv;



         Auxcount:=1;
         /*Moneda Funcional*/
         open get_agrupado_info_mf();
            loop
            fetch get_agrupado_info_mf into agrupado_info_rec_mf;
            exit when get_agrupado_info_mf%notfound;

                 select distinct(SUBSTR(CUENTA,1,4))  into lt_moneda_funcional_tbl(Auxcount).cuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
                  select distinct(SUBSTR(CUENTA,6,5))  into lt_moneda_funcional_tbl(Auxcount).subcuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
               select distinct(NUM_RUBRO)  into lt_moneda_funcional_tbl(Auxcount).num_rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
                select distinct(NAME_RUB)  into lt_moneda_funcional_tbl(Auxcount).rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select distinct(CONCEPTO)  into lt_moneda_funcional_tbl(Auxcount).concepto from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(SALDO_INICIAL) into lt_moneda_funcional_tbl(Auxcount).saldo_inicial from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(ADICIONES)into lt_moneda_funcional_tbl(Auxcount).ad_altas  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(Depr_Ejercicio) into lt_moneda_funcional_tbl(Auxcount).depn_del_ejercicio  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(SUMA) into lt_moneda_funcional_tbl(Auxcount).suma from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(SDO_FINAL) into lt_moneda_funcional_tbl(Auxcount).saldo_final  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              
              select sum(mf_resultados) into lt_moneda_funcional_tbl(Auxcount).mf_resultados  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
              select sum(mf_balance) into lt_moneda_funcional_tbl(Auxcount).mf_balance  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
           
                 
              auxSInicial_mf:=nvl(auxSInicial_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).saldo_inicial,0);
              auxAdic_mf:=nvl(auxAdic_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).ad_altas,0);
              auxDep_Ej_mf:=nvl(auxDep_Ej_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).depn_del_ejercicio,0);
              auxSuma_mf:=nvl(auxSuma_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).suma,0);
              auxSdo_F_mf:=nvl(auxSdo_F_mf,0) +  nvl(lt_moneda_funcional_tbl(Auxcount).saldo_final,0);
              
              aux_mf_resultados := nvl(aux_mf_resultados,0) + lt_moneda_funcional_tbl(Auxcount).mf_resultados; 
              aux_mf_balance := nvl(aux_mf_balance ,0) + lt_moneda_funcional_tbl(Auxcount).mf_balance ; 

               Auxcount:=Auxcount+1;
             end loop;

         close get_agrupado_info_mf;
         /*subtotales*/
         lt_subtotal_mf_info_rec.agrupado:='MF';
         lt_subtotal_mf_info_rec.saldo_inicial:=auxSInicial_mf;
          lt_subtotal_mf_info_rec.ad_altas:=auxAdic_mf;
          lt_subtotal_mf_info_rec.depn_del_ejercicio:=auxDep_Ej_mf;
         lt_subtotal_mf_info_rec.suma:= auxSuma_mf;
         lt_subtotal_mf_info_rec.saldo_final:=auxSdo_F_mf;
         lt_subtotal_mf_info_rec.mf_resultados := aux_mf_resultados; 
         lt_subtotal_mf_info_rec.mf_balance := aux_mf_balance; 


         Auxcount:=1;
         /*Depreciacion*/
         open get_agrupado_info_dpn();
            loop
            fetch get_agrupado_info_dpn into agrupado_info_rec_dpn;
            exit when get_agrupado_info_dpn%notfound;


               -- select sum(SALDO_INICIAL) into v1257_16001_Sin_inv from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_mf.cuenta;
               --dbms_output.put_line('sdo_inicial: '|| v1257_16001_Sin_inv);
               select distinct(SUBSTR(CUENTA,1,4)) into lt_depreciacion_tbl(Auxcount).cuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
               select distinct(SUBSTR(CUENTA,6,5)) into lt_depreciacion_tbl(Auxcount).subcuenta from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select distinct(NUM_RUBRO)  into lt_depreciacion_tbl(Auxcount).num_rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select distinct(NAME_RUB)  into lt_depreciacion_tbl(Auxcount).rubro from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select distinct(CONCEPTO)  into lt_depreciacion_tbl(Auxcount).concepto from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(SALDO_INICIAL) into lt_depreciacion_tbl(Auxcount).saldo_inicial from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(ADICIONES)into lt_depreciacion_tbl(Auxcount).ad_altas  from  XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(Depr_Ejercicio) into lt_depreciacion_tbl(Auxcount).depn_del_ejercicio  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(SUMA) into lt_depreciacion_tbl(Auxcount).suma from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;
              select sum(SDO_FINAL) into lt_depreciacion_tbl(Auxcount).saldo_final  from XXGAM_SAF_ACUM_R12 where cuenta=agrupado_info_rec_dpn.cuenta;

              auxSinicial_dpn:=nvl(auxSinicial_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).saldo_inicial,0);
              auxAdic_dpn:=nvl(auxAdic_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).ad_altas,0);
              auxDep_Ej_dpn:=nvl(auxDep_Ej_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).depn_del_ejercicio,0);
              auxSuma_dpn:=nvl(auxSuma_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).suma,0);
              auxSdo_F_dpn:=nvl(auxSdo_F_dpn,0) + nvl(lt_depreciacion_tbl(Auxcount).saldo_final,0);
               Auxcount:=Auxcount+1;
             end loop;

         close get_agrupado_info_dpn;
         lt_subtotal_dpn_info_rec.agrupado:='DPN';
          lt_subtotal_dpn_info_rec.saldo_inicial:=auxSinicial_dpn;
          lt_subtotal_dpn_info_rec.depn_del_ejercicio:=auxDep_Ej_dpn;
           lt_subtotal_dpn_info_rec.suma:=auxSuma_dpn;
           lt_subtotal_dpn_info_rec.saldo_final:=auxSdo_F_dpn;

          /*VNL*/
          lt_subtotal_vnl_info_rec.saldo_inicial:=auxSinicial_dpn+auxSInicial_mf+auxSInicial;
          lt_subtotal_vnl_info_rec.ad_altas:=auxAdic_inv+auxAdic_mf +auxAdic_dpn;
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
procedure main (pso_errmsg out varchar2
              , pso_errcod out varchar2
              ,  psi_operating_unit  in VARCHAR2
              ,  psi_periodo_final in varchar2
              ,  psi_divisa in varchar2
              ,  pro_tt_by_rubro_rec  out XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec
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
var1 varchar2(100);
var2 varchar2(100);
auxContador number;
LPRO_TT_BY_RUBRO_REC XXGAM_SAF_OP_MEN_PKG.T_BY_RUBRO_REC;
lt_inversion_tbl                  XXGAM_SAF_OP_MEN_PKG.t_inversion_tbl;    /*tabla*/
ltt_inversion_set_rec                XXGAM_SAF_OP_MEN_PKG.t_inversion_set_rec;  /*SET*/

begin

            Fnd_file.put_line(Fnd_file.log, 'Comienza ENA main log');

         open get_agrupado_info(psi_periodo_final );
        loop
        fetch get_agrupado_info into agrupado_info_rec;
        exit when get_agrupado_info%notfound;

          Fnd_file.put_line(Fnd_file.log,'Ejecutar execute_main_r12: '||agrupado_info_rec.PERIOD_NAME);
        /**Ejecutamos n veces el procedure r12 que inserta en la #tabla**/

           XXGAM_SAF_EXE_ACUM_RUB12_PKG.execute_main_r12( PSO_ERRMSG         => var1
                                                         ,PSO_ERRCOD         => var2
                                                         ,PSI_PERIODO        => agrupado_info_rec.PERIOD_NAME
                                                         ,PSI_OPERATING_UNIT => psi_operating_unit
                                                         ,PSI_DIVISA         => psi_divisa
                                                         );
           Fnd_file.put_line(Fnd_file.log,'Ejecutar execute_main_r12');
         end loop;
           Fnd_file.put_line(Fnd_file.log,'----------> Row Count:'||get_agrupado_info%rowcount);
         close get_agrupado_info;

        Fnd_file.put_line(Fnd_file.log,'ejecutando acumulado...');

        --execute_setAcumulado_r12(var1,var2,PRO_TT_BY_RUBRO_REC);
        XXGAM_SAF_EXE_ACUM_RUB12_PKG.execute_setAcumulado_r12( PSO_ERRMSG         => var1
                                                 ,PSO_ERRCOD         => var2
                                               ,PRO_TT_BY_RUBRO_REC => LPRO_TT_BY_RUBRO_REC );


      --  LPRO_TT_BY_RUBRO_REC:=PRO_TT_BY_RUBRO_REC;
      pro_tt_by_rubro_rec:= LPRO_TT_BY_RUBRO_REC;
         commit;
    -- LPRO_TT_BY_RUBRO_REC.lt_inversion_tbl.


     ltt_inversion_set_rec:=LPRO_TT_BY_RUBRO_REC.et_inversion_set_rec;
         lt_inversion_tbl:=ltt_inversion_set_rec.et_inversion_tbl;

        Fnd_file.put_line(Fnd_file.log, 'Finaliza ENA main log');

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

            end main;
END  XXGAM_SAF_EXE_ACUM_RUB12_PKG; 
/

