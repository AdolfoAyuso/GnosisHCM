CREATE OR REPLACE PACKAGE BODY APPS.XXGAM_SAF_OP_MEN_PKG AS

 gs_curr_format  varchar2(100) := '999,999,999,999,999,999.999999'; 

 procedure main (pso_errmsg    out varchar2 
                ,pso_errcod    out varchar2) is 
 ls_errmsg          varchar2(2000); 
 ls_errcod          varchar2(2000);           
 
 le_t_op_men_tbl    XXGAM_SAF_OP_MEN_PKG.t_op_men_tbl;      
 le_main_exception  exception;  
 begin 
  ls_errmsg :=  null; 
  ls_errcod := '0'; 
  
  fnd_file.put_line(fnd_file.log,'Comienza Main'); 
  
  xxgam_saf_op_men_pkg.ejecuta_op_men(pso_errmsg      => ls_errmsg
                                     ,pso_errcod      => ls_errcod
                                     ,pto_op_men_tbl  => le_t_op_men_tbl 
                                      ); 
                                      
  if ls_errmsg is not null  then 
   ls_errmsg := 'Excepcion al ejecutar ejecuta_op_men:'||ls_errmsg; 
   raise le_main_exception; 
  end if; 
  
--  xxgam_saf_op_men_pkg.print_op_men(pso_errmsg       => ls_errmsg
--                                   ,pso_errcod       => ls_errcod
--                                   ,pti_tt_by_rubro_rec   => le_t_op_men_tbl
--                                   );      
  
   if ls_errmsg is not null  then 
   ls_errmsg := 'Excepcion al ejecutar print_op_men:'||ls_errmsg; 
   raise le_main_exception; 
  end if;                                                     
  
  fnd_file.put_line(fnd_file.log,'Finaliza Main');                                  
  
  pso_errmsg := ls_errmsg; 
  pso_errcod := ls_errcod; 
  
 exception when le_main_exception then 
  
 fnd_file.put_line(fnd_file.log,'Exception le_main_exception');     
  
  ls_errcod := '2';
  pso_errmsg := ls_errmsg; 
  pso_errcod := ls_errcod; 
  
  when others then 
  
  fnd_file.put_line(fnd_file.log,'Exception Main');     
  
  ls_errmsg :=  'Exception Procedure Main:'||sqlerrm||' ,'||sqlcode; 
  ls_errcod := '2';
  pso_errmsg := ls_errmsg; 
  pso_errcod := ls_errcod; 
  
 end; 

 procedure op_men_execute_insert(pti_op_men_tbl   IN OUT t_op_men_tbl) is 
 begin 
  null; 
 exception when others then 
  null; 
 end; 
   
 procedure op_men_execute_update(pti_op_men_tbl   IN OUT t_op_men_tbl) is 
  begin 
   null; 
 exception when others then 
  null; 
 end; 
  
 procedure op_men_execute_delete(pti_op_men_tbl   IN OUT t_op_men_tbl) is 
  begin 
  null; 
 exception when others then 
  null; 
 end; 
 
 procedure op_men_execute_lock(pti_op_men_tbl   IN OUT t_op_men_tbl) is 
  begin 
  null; 
 exception when others then 
  null; 
 end; 
 
 
 procedure ejecuta_op_men(pso_errmsg      out  varchar2 
                         ,pso_errcod      out  varchar2
                         ,pto_op_men_tbl  out  xxgam_saf_op_men_pkg.t_op_men_tbl 
                          ) is
 
 
 CURSOR get_inversion_info IS
     select CUENTA
       ,SUBCUENTA
       ,RUBRO
       ,AGRUPADO
   from XXGAM_SAF_SETUP
  where AGRUPADO = 'INVERSION'; 
  
  CURSOR get_mf_info IS
    select CUENTA
          ,SUBCUENTA
          ,RUBRO
          ,AGRUPADO
     from XXGAM_SAF_SETUP
    where AGRUPADO = 'MF'; 
  
  CURSOR get_dpn_info IS
    select CUENTA
          ,SUBCUENTA
          ,RUBRO
          ,AGRUPADO
     from XXGAM_SAF_SETUP
    where AGRUPADO = 'DPN'; 
   
     
  
  inversion_info_rec    get_inversion_info%ROWTYPE;
  mf_info_rec           get_mf_info%ROWTYPE;
  dpn_info_rec          get_dpn_info%ROWTYPE;
      
 
 
 lt_op_men_tbl                xxgam_saf_op_men_pkg.t_op_men_tbl; 
 let_inversion_tbl            xxgam_saf_op_men_pkg.t_inversion_tbl; 
 let_moneda_funcional_tbl     xxgam_saf_op_men_pkg.t_moneda_funcional_tbl;
 let_depreciacion_tbl         xxgam_saf_op_men_pkg.t_depreciacion_tbl;
 let_subtotal_vnl_rec         xxgam_saf_op_men_pkg.t_subtotal_vnl_rec; 
 
 ln_op_men_idx                binary_integer; 
 ln_inversion_idx             binary_integer;
 ln_moneda_funcional_idx      binary_integer;
 ln_dpn_idx                   binary_integer;
  
 let_inv_subtotal_rec        t_subtotal_agrupado_rec;
 
 
 let_inversion_set_rec           xxgam_saf_op_men_pkg.t_inversion_set_rec;
 let_moneda_funcional_set_rec    xxgam_saf_op_men_pkg.t_moneda_funcional_set_rec;
 let_depreciacion_set_rec        xxgam_saf_op_men_pkg.t_depreciacion_set_rec; 
 
 begin 
 
 pso_errmsg := null; 
 pso_errcod := '0';
 
 fnd_file.put_line(fnd_file.log,'Comienza ejecuta_op_men'); 
 
 ln_op_men_idx := 1; 
 
   OPEN get_inversion_info;
     LOOP
        FETCH get_inversion_info INTO inversion_info_rec;
        EXIT WHEN get_inversion_info%NOTFOUND;
        
        ln_inversion_idx := get_inversion_info%ROWCOUNT; 
        
        let_inversion_tbl(ln_inversion_idx).rubro                 := inversion_info_rec.RUBRO;     
        let_inversion_tbl(ln_inversion_idx).cuenta                := inversion_info_rec.cuenta;    
        let_inversion_tbl(ln_inversion_idx).subcuenta             := inversion_info_rec.subcuenta; 
        
        let_inversion_tbl(ln_inversion_idx).concepto              := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).saldo_inicial         := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).ad_altas              := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).ad_dism_inversa       := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).ad_transferencia      := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr      := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta       := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).ret_dpn_sin_ingr      := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).ret_dpn_x_venta       := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).depn_del_ejercicio    := 9999999.99;
        let_inversion_tbl(ln_inversion_idx).suma                   :=9999999.99;
        let_inversion_tbl(ln_inversion_idx).saldo_final           := 9999999.99;
        
     END LOOP;
   CLOSE get_inversion_info;
     
 /******************************************************************************
 
 ln_inversion_idx := 1; 
 
 let_inversion_tbl(ln_inversion_idx).rubro                 := 'rubro'; 
 let_inversion_tbl(ln_inversion_idx).cuenta                := 'cuenta';
 let_inversion_tbl(ln_inversion_idx).subcuenta             := 'subcuenta';
 let_inversion_tbl(ln_inversion_idx).concepto              := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).saldo_inicial         := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_altas              := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_dism_inversa       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_transferencia      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_dpn_sin_ingr      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_dpn_x_venta       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).depn_del_ejercicio    := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).saldo_final           := 9999999.99;
 
 ln_inversion_idx := 2; 
 
 let_inversion_tbl(ln_inversion_idx).rubro                 := 'rubro'; 
 let_inversion_tbl(ln_inversion_idx).cuenta                := 'cuenta';
 let_inversion_tbl(ln_inversion_idx).subcuenta             := 'subcuenta';
 let_inversion_tbl(ln_inversion_idx).concepto              := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).saldo_inicial         := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_altas              := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_dism_inversa       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_transferencia      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_dpn_sin_ingr      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_dpn_x_venta       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).depn_del_ejercicio    := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).saldo_final           := 9999999.99;
 
 ln_inversion_idx := 3; 
 
 let_inversion_tbl(ln_inversion_idx).rubro                 := 'rubro'; 
 let_inversion_tbl(ln_inversion_idx).cuenta                := 'cuenta';
 let_inversion_tbl(ln_inversion_idx).subcuenta             := 'subcuenta';
 let_inversion_tbl(ln_inversion_idx).concepto              := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).saldo_inicial         := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_altas              := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_dism_inversa       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ad_transferencia      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_moi_sin_ingr      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_moi_x_venta       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_dpn_sin_ingr      := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).ret_dpn_x_venta       := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).depn_del_ejercicio    := 9999999.99;
 let_inversion_tbl(ln_inversion_idx).saldo_final           := 9999999.99;
 
 *******************************************************************************/
 
 let_inv_subtotal_rec.agrupado           := 'INVERSION';
 let_inv_subtotal_rec.saldo_inicial      := 9999999.99;
 let_inv_subtotal_rec.ad_altas           := 9999999.99;
 let_inv_subtotal_rec.ad_dism_inversa    := 9999999.99;
 let_inv_subtotal_rec.ad_transferencia   := 9999999.99; 
 let_inv_subtotal_rec.ret_moi_sin_ingr   := 9999999.99; 
 let_inv_subtotal_rec.ret_moi_x_venta    := 9999999.99;
 let_inv_subtotal_rec.ret_dpn_sin_ingr   := 9999999.99;
 let_inv_subtotal_rec.ret_dpn_x_venta    := 9999999.99;
 let_inv_subtotal_rec.depn_del_ejercicio := 9999999.99;
 let_inv_subtotal_rec.suma                   := 9999999.99;
 let_inv_subtotal_rec.saldo_final        := 9999999.99;
 
 
 let_inversion_set_rec.et_inversion_tbl         := let_inversion_tbl;
 let_inversion_set_rec.et_subtotal_agrupado_rec := let_inv_subtotal_rec; 
 
 
  OPEN get_mf_info;
    LOOP
       FETCH get_mf_info INTO mf_info_rec;
       EXIT WHEN get_mf_info%NOTFOUND;
       
       ln_moneda_funcional_idx := get_mf_info%ROWCOUNT; 
       
       let_moneda_funcional_tbl(ln_moneda_funcional_idx).rubro     := mf_info_rec.RUBRO;     
       let_moneda_funcional_tbl(ln_moneda_funcional_idx).cuenta    := mf_info_rec.cuenta;     
       let_moneda_funcional_tbl(ln_moneda_funcional_idx).subcuenta := mf_info_rec.subcuenta;
       
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).concepto              := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).saldo_inicial         := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).ad_altas              := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).ad_dism_inversa       := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).ad_transferencia      := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).ret_moi_sin_ingr      := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).ret_moi_x_venta       := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).ret_dpn_sin_ingr      := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).ret_dpn_x_venta       := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).depn_del_ejercicio    := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).suma                       := 9999999.99;
        let_moneda_funcional_tbl(ln_moneda_funcional_idx).saldo_final           := 9999999.99;
         
    END LOOP;
   CLOSE get_mf_info;
   
 let_inv_subtotal_rec.agrupado           := 'MF';
 let_inv_subtotal_rec.saldo_inicial      := 9999999.99;
 let_inv_subtotal_rec.ad_altas           := 9999999.99;
 let_inv_subtotal_rec.ad_dism_inversa    := 9999999.99;
 let_inv_subtotal_rec.ad_transferencia   := 9999999.99; 
 let_inv_subtotal_rec.ret_moi_sin_ingr   := 9999999.99; 
 let_inv_subtotal_rec.ret_moi_x_venta    := 9999999.99;
 let_inv_subtotal_rec.ret_dpn_sin_ingr   := 9999999.99;
 let_inv_subtotal_rec.ret_dpn_x_venta    := 9999999.99;
 let_inv_subtotal_rec.depn_del_ejercicio := 9999999.99;
 let_inv_subtotal_rec.suma := 9999999.99;
 let_inv_subtotal_rec.saldo_final        := 9999999.99;
  
 let_moneda_funcional_set_rec.et_moneda_funcional_tbl    := let_moneda_funcional_tbl;
 let_moneda_funcional_set_rec.et_subtotal_agrupado_rec   := let_inv_subtotal_rec;
 
   
    OPEN get_dpn_info;
   LOOP
      FETCH get_dpn_info INTO dpn_info_rec;
      EXIT WHEN get_dpn_info%NOTFOUND;
      
      ln_dpn_idx := get_dpn_info%ROWCOUNT; 
       
      let_depreciacion_tbl(ln_dpn_idx).rubro                 := dpn_info_rec.RUBRO;     
      let_depreciacion_tbl(ln_dpn_idx).cuenta                := dpn_info_rec.cuenta;     
      let_depreciacion_tbl(ln_dpn_idx).subcuenta             := dpn_info_rec.subcuenta;
       
      let_depreciacion_tbl(ln_dpn_idx).concepto              := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).saldo_inicial         := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).ad_altas              := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).ad_dism_inversa       := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).ad_transferencia      := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).ret_moi_sin_ingr      := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).ret_moi_x_venta       := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).ret_dpn_sin_ingr      := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).ret_dpn_x_venta       := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).depn_del_ejercicio    := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).suma                       := 9999999.99;
      let_depreciacion_tbl(ln_dpn_idx).saldo_final           := 9999999.99;
      
   END LOOP;
   CLOSE get_dpn_info;
   
 let_inv_subtotal_rec.agrupado           := 'DPN';
 let_inv_subtotal_rec.saldo_inicial      := 9999999.99;
 let_inv_subtotal_rec.ad_altas           := 9999999.99;
 let_inv_subtotal_rec.ad_dism_inversa    := 9999999.99;
 let_inv_subtotal_rec.ad_transferencia   := 9999999.99; 
 let_inv_subtotal_rec.ret_moi_sin_ingr   := 9999999.99; 
 let_inv_subtotal_rec.ret_moi_x_venta    := 9999999.99;
 let_inv_subtotal_rec.ret_dpn_sin_ingr   := 9999999.99;
 let_inv_subtotal_rec.ret_dpn_x_venta    := 9999999.99;
 let_inv_subtotal_rec.depn_del_ejercicio := 9999999.99;
 let_inv_subtotal_rec.suma                   := 9999999.99;
 let_inv_subtotal_rec.saldo_final        := 9999999.99; 
 
 let_depreciacion_set_rec.et_depreciacion_tbl         := let_depreciacion_tbl;
 let_depreciacion_set_rec.et_subtotal_agrupado_rec    := let_inv_subtotal_rec;
 
   
 lt_op_men_tbl(ln_op_men_idx).et_inversion_set_rec         := let_inversion_set_rec; 
 lt_op_men_tbl(ln_op_men_idx).et_moneda_funcional_set_rec  := let_moneda_funcional_set_rec;
 lt_op_men_tbl(ln_op_men_idx).et_depreciacion_set_rec      := let_depreciacion_set_rec;
 lt_op_men_tbl(ln_op_men_idx).et_subtotal_vnl_rec          := let_subtotal_vnl_rec; 
 
 
 pto_op_men_tbl := lt_op_men_tbl;
 
 fnd_file.put_line(fnd_file.log,'Finaliza ejecuta_op_men'); 
  
 exception when others then 
  fnd_file.put_line(fnd_file.log,'Exception ejecuta_op_men:'||sqlerrm||' ,'||sqlcode); 
  pso_errmsg := 'Exception ejecuta_op_men:'||sqlerrm||' ,'||sqlcode; 
  pso_errcod := '2';
  
 
 end; 
                          
 
 procedure   print_op_men(pso_errmsg            out varchar2 
                         ,pso_errcod            out varchar2
                         ,pti_tt_by_rubro_rec   in  t_by_rubro_rec) is 
 
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
   fnd_file.put_line(fnd_file.output,'<RUBRO>');  
  
   for idx in let_inversion_tbl.first .. let_inversion_tbl.last loop  
   fnd_file.put_line(fnd_file.output,'<COLUMNAS>');
   fnd_file.put_line(fnd_file.output,'<INF_RUBRO>'||let_inversion_tbl(idx).rubro||'</INF_RUBRO>');
   fnd_file.put_line(fnd_file.output,'<ID_RUBRO>'||let_inversion_tbl(idx).num_rubro||'</ID_RUBRO>');
   fnd_file.put_line(fnd_file.output,'<CUENTA>'||let_inversion_tbl(idx).cuenta||'-'||let_inversion_tbl(idx).subcuenta||'</CUENTA>'); 
   fnd_file.put_line(fnd_file.output,'<CONCEPTO>'||let_inversion_tbl(idx).concepto||'</CONCEPTO>');    
   fnd_file.put_line(fnd_file.output,'<AA_PAS>'||trim(to_char(let_inversion_tbl(idx).saldo_inicial,gs_curr_format))||'</AA_PAS>');  
   fnd_file.put_line(fnd_file.output,'<DEB_AC>'||trim(to_char(let_inversion_tbl(idx).ad_altas,gs_curr_format))||'</DEB_AC>');  
   fnd_file.put_line(fnd_file.output,'<CRED>'||trim(to_char(let_inversion_tbl(idx).ad_dism_inversa,gs_curr_format))||'</CRED>'); 
   fnd_file.put_line(fnd_file.output,'<AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_inversion_tbl(idx).ad_transferencia,gs_curr_format))||'</AD_TRANSFERENCIA_ATTR>'); 
   /** Se agregarn en un futuro no lejano **/
   fnd_file.put_line(fnd_file.output,'<RET_MOI_SIN_INGR_ATTR>'||trim(to_char(let_inversion_tbl(idx).ret_moi_sin_ingr,gs_curr_format))||'</RET_MOI_SIN_INGR_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_MOI_X_VENTA_ATTR>'||trim(to_char(let_inversion_tbl(idx).ret_moi_x_venta,gs_curr_format))||'</RET_MOI_X_VENTA_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_DPN_SIN_INGR_ATTR>'||trim(to_char(let_inversion_tbl(idx).ret_dpn_sin_ingr,gs_curr_format))||'</RET_DPN_SIN_INGR_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_DPN_X_VENTA_ATTR>'||trim(to_char(let_inversion_tbl(idx).ret_dpn_x_venta,gs_curr_format))||'</RET_DPN_X_VENTA_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<DPN>'||trim(to_char(let_inversion_tbl(idx).depn_del_ejercicio,gs_curr_format))||'</DPN>');
   fnd_file.put_line(fnd_file.output,'<ACUM_PERIOD>'||trim(to_char(let_inversion_tbl(idx).suma,gs_curr_format))||'</ACUM_PERIOD>');
   fnd_file.put_line(fnd_file.output,'<ACUM_ANUAL>'||trim(to_char(let_inversion_tbl(idx).saldo_final,gs_curr_format))||'</ACUM_ANUAL>');
   fnd_file.put_line(fnd_file.output,'</COLUMNAS>');  
  end loop;
  
  fnd_file.put_line(fnd_file.output,'<AGRUPADO>'||let_inv_subtotal_rec.agrupado||'</AGRUPADO>');
  fnd_file.put_line(fnd_file.output,'<SUB_AAA>'||trim(to_char(let_inv_subtotal_rec.saldo_inicial,gs_curr_format))||'</SUB_AAA>');
  fnd_file.put_line(fnd_file.output,'<SUB_DEB_AC>'||trim(to_char(let_inv_subtotal_rec.ad_altas,gs_curr_format))||'</SUB_DEB_AC>');
  fnd_file.put_line(fnd_file.output,'<SUB_CRED>'||trim(to_char(let_inv_subtotal_rec.ad_dism_inversa,gs_curr_format))||'</SUB_CRED>');
  fnd_file.put_line(fnd_file.output,'<SUB_AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_inv_subtotal_rec.ad_transferencia,gs_curr_format))||'</SUB_AD_TRANSFERENCIA_ATTR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_MOI_SIN_INGR>'||trim(to_char(let_inv_subtotal_rec.ret_moi_sin_ingr,gs_curr_format))||'</SUB_RET_MOI_SIN_INGR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_MOI_X_VENTA>'||trim(to_char(let_inv_subtotal_rec.ret_moi_x_venta,gs_curr_format))||'</SUB_RET_MOI_X_VENTA>'); 
  
  
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  fnd_file.put_line(fnd_file.output,'<SUB_RET_DPN_SIN_INGR>'||trim(to_char(let_inv_subtotal_rec.ret_dpn_sin_ingr,gs_curr_format))||'</SUB_RET_DPN_SIN_INGR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_DPN_X_VENTA>'||trim(to_char(let_inv_subtotal_rec.ret_dpn_x_venta,gs_curr_format))||'</SUB_RET_DPN_X_VENTA>'); 
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  
  
  
  fnd_file.put_line(fnd_file.output,'<SUB_DPN>'||trim(to_char(let_inv_subtotal_rec.depn_del_ejercicio,gs_curr_format))||'</SUB_DPN>');
  fnd_file.put_line(fnd_file.output,'<SUB_AP>'||trim(to_char(let_inv_subtotal_rec.suma,gs_curr_format))||'</SUB_AP>');
  fnd_file.put_line(fnd_file.output,'<SUB_AA>'||trim(to_char(let_inv_subtotal_rec.saldo_final,gs_curr_format))||'</SUB_AA>');
  
  fnd_file.put_line(fnd_file.output,'</RUBRO>');  
  
   end if; /** END  if 3 = ln_stop_step2 then  **/
  
  end if; /** END  if let_inversion_tbl.count >0 then  **/
  
  
   if let_moneda_funcional_tbl.count >0 then 
  
   if 3 = ln_stop_step3 then 
  
  fnd_file.put_line(fnd_file.output,'<RUBRO>');  
  
  for idx in let_moneda_funcional_tbl.first .. let_moneda_funcional_tbl.last loop  
   fnd_file.put_line(fnd_file.output,'<COLUMNAS>');
   fnd_file.put_line(fnd_file.output,'<INF_RUBRO>'||let_moneda_funcional_tbl(idx).rubro||'</INF_RUBRO>');
   fnd_file.put_line(fnd_file.output,'<ID_RUBRO>'||let_moneda_funcional_tbl(idx).num_rubro||'</ID_RUBRO>');
   fnd_file.put_line(fnd_file.output,'<CUENTA>'||let_moneda_funcional_tbl(idx).cuenta||'-'||let_moneda_funcional_tbl(idx).subcuenta||'</CUENTA>'); 
   fnd_file.put_line(fnd_file.output,'<CONCEPTO>'||let_moneda_funcional_tbl(idx).concepto||'</CONCEPTO>');    
   fnd_file.put_line(fnd_file.output,'<AA_PAS>'||trim(to_char(let_moneda_funcional_tbl(idx).saldo_inicial,gs_curr_format))||'</AA_PAS>');  
   fnd_file.put_line(fnd_file.output,'<DEB_AC>'||trim(to_char(let_moneda_funcional_tbl(idx).ad_altas,gs_curr_format))||'</DEB_AC>');  
   fnd_file.put_line(fnd_file.output,'<CRED>'||trim(to_char(let_moneda_funcional_tbl(idx).ad_dism_inversa,gs_curr_format))||'</CRED>'); 
   fnd_file.put_line(fnd_file.output,'<AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ad_transferencia,gs_curr_format))||'</AD_TRANSFERENCIA_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_MOI_SIN_INGR_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ret_moi_sin_ingr,gs_curr_format))||'</RET_MOI_SIN_INGR_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_MOI_X_VENTA_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ret_moi_x_venta,gs_curr_format))||'</RET_MOI_X_VENTA_ATTR>'); 
   
   
   /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
   fnd_file.put_line(fnd_file.output,'<RET_DPN_SIN_INGR_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ret_dpn_sin_ingr,gs_curr_format))||'</RET_DPN_SIN_INGR_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_DPN_X_VENTA_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ret_dpn_x_venta,gs_curr_format))||'</RET_DPN_X_VENTA_ATTR>'); 
     /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/

   
   
   
   
   fnd_file.put_line(fnd_file.output,'<DPN>'||trim(to_char(let_moneda_funcional_tbl(idx).depn_del_ejercicio,gs_curr_format))||'</DPN>');
   fnd_file.put_line(fnd_file.output,'<ACUM_PERIOD>'||trim(to_char(let_moneda_funcional_tbl(idx).suma,gs_curr_format))||'</ACUM_PERIOD>');
   fnd_file.put_line(fnd_file.output,'<ACUM_ANUAL>'||trim(to_char(let_moneda_funcional_tbl(idx).saldo_final,gs_curr_format))||'</ACUM_ANUAL>');
   fnd_file.put_line(fnd_file.output,'</COLUMNAS>');  
  end loop;
  
  fnd_file.put_line(fnd_file.output,'<AGRUPADO>'||let_mf_subtotal_rec .agrupado||'</AGRUPADO>');
  fnd_file.put_line(fnd_file.output,'<SUB_AAA>'||trim(to_char(let_mf_subtotal_rec .saldo_inicial,gs_curr_format))||'</SUB_AAA>');
  fnd_file.put_line(fnd_file.output,'<SUB_DEB_AC>'||trim(to_char(let_mf_subtotal_rec .ad_altas,gs_curr_format))||'</SUB_DEB_AC>');
  fnd_file.put_line(fnd_file.output,'<SUB_CRED>'||trim(to_char(let_mf_subtotal_rec .ad_dism_inversa,gs_curr_format))||'</SUB_CRED>');
  fnd_file.put_line(fnd_file.output,'<SUB_AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_mf_subtotal_rec.ad_transferencia,gs_curr_format))||'</SUB_AD_TRANSFERENCIA_ATTR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_MOI_SIN_INGR>'||trim(to_char(let_mf_subtotal_rec.ret_moi_sin_ingr,gs_curr_format))||'</SUB_RET_MOI_SIN_INGR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_MOI_X_VENTA>'||trim(to_char(let_mf_subtotal_rec.ret_moi_x_venta,gs_curr_format))||'</SUB_RET_MOI_X_VENTA>'); 
  
  
  
  
   /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  fnd_file.put_line(fnd_file.output,'<SUB_RET_DPN_SIN_INGR>'||trim(to_char(let_mf_subtotal_rec.ret_dpn_sin_ingr,gs_curr_format))||'</SUB_RET_DPN_SIN_INGR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_DPN_X_VENTA>'||trim(to_char(let_mf_subtotal_rec.ret_dpn_x_venta,gs_curr_format))||'</SUB_RET_DPN_X_VENTA>'); 
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
 
  
  
  fnd_file.put_line(fnd_file.output,'<SUB_DPN>'||trim(to_char(let_mf_subtotal_rec.depn_del_ejercicio,gs_curr_format))||'</SUB_DPN>');
  fnd_file.put_line(fnd_file.output,'<SUB_AP>'||trim(to_char(let_mf_subtotal_rec.suma,gs_curr_format))||'</SUB_AP>');
  fnd_file.put_line(fnd_file.output,'<SUB_AA>'||trim(to_char(let_mf_subtotal_rec.saldo_final,gs_curr_format))||'</SUB_AA>');
  
  fnd_file.put_line(fnd_file.output,'</RUBRO>');  
  
   end if; /** END if 4 = ln_stop_step3 then  **/ 
  
  end if; /** END if let_moneda_funcional_tbl.count >0 then  **/
  
  
  /** ENTER DEPRECIACION **/
  
   fnd_file.put_line(fnd_file.log,'Count Dpn Table:'||let_depreciacion_tbl.count); 
   if let_depreciacion_tbl.count > 0 then  
   if 4 = ln_stop_step4 then 
 
   fnd_file.put_line(fnd_file.output,'<RUBRO>');  
  
  for idx in let_depreciacion_tbl.first .. let_depreciacion_tbl.last loop  
   fnd_file.put_line(fnd_file.output,'<COLUMNAS>');
   fnd_file.put_line(fnd_file.output,'<INF_RUBRO>'||let_depreciacion_tbl(idx).rubro||'</INF_RUBRO>');
   fnd_file.put_line(fnd_file.output,'<ID_RUBRO>'||let_depreciacion_tbl(idx).num_rubro||'</ID_RUBRO>');
   fnd_file.put_line(fnd_file.output,'<CUENTA>'||let_depreciacion_tbl(idx).cuenta||'-'||let_depreciacion_tbl(idx).subcuenta||'</CUENTA>'); 
   fnd_file.put_line(fnd_file.output,'<CONCEPTO>'||let_depreciacion_tbl(idx).concepto||'</CONCEPTO>');    
   fnd_file.put_line(fnd_file.output,'<AA_PAS>'||trim(to_char(let_depreciacion_tbl(idx).saldo_inicial,gs_curr_format))||'</AA_PAS>');  
   fnd_file.put_line(fnd_file.output,'<DEB_AC>'||trim(to_char(let_depreciacion_tbl(idx).ad_altas,gs_curr_format))||'</DEB_AC>');  
   fnd_file.put_line(fnd_file.output,'<CRED>'||trim(to_char(let_depreciacion_tbl(idx).ad_dism_inversa,gs_curr_format))||'</CRED>'); 
   fnd_file.put_line(fnd_file.output,'<AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ad_transferencia,gs_curr_format))||'</AD_TRANSFERENCIA_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_MOI_SIN_INGR_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ret_moi_sin_ingr,gs_curr_format))||'</RET_MOI_SIN_INGR_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_MOI_X_VENTA_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ret_moi_x_venta,gs_curr_format))||'</RET_MOI_X_VENTA_ATTR>'); 
   
   /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
   fnd_file.put_line(fnd_file.output,'<RET_DPN_SIN_INGR_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ret_dpn_sin_ingr,gs_curr_format))||'</RET_DPN_SIN_INGR_ATTR>'); 
   fnd_file.put_line(fnd_file.output,'<RET_DPN_X_VENTA_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ret_dpn_x_venta,gs_curr_format))||'</RET_DPN_X_VENTA_ATTR>'); 
     /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
     
     
     
     
     

   
   /** Se agregarn en un futuro no lejano **/
   /*****************************************
   fnd_file.put_line(fnd_file.output,'<RET_MOI_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_moi_sin_ingr||'</RET_MOI_SIN_INGR_ATTR>'); 
   dbms_output.put_line('<RET_MOI_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_moi_sin_ingr||'</RET_MOI_SIN_INGR_ATTR>');
   fnd_file.put_line(fnd_file.output,'<RET_MOI_X_VENTA_ATTR>'||let_depreciacion_tbl(idx).ad_transferencia||'</RET_MOI_X_VENTA_ATTR>'); 
   dbms_output.put_line('<RET_MOI_X_VENTA_ATTR>'||let_depreciacion_tbl(idx).ad_transferencia||'</RET_MOI_X_VENTA_ATTR>');
   fnd_file.put_line(fnd_file.output,'<RET_DPN_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_SIN_INGR_ATTR>'); 
   dbms_output.put_line('<RET_DPN_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_SIN_INGR_ATTR>');
   fnd_file.put_line(fnd_file.output,'<RET_DPN_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_SIN_INGR_ATTR>'); 
   dbms_output.put_line('<RET_DPN_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_SIN_INGR_ATTR>');
   fnd_file.put_line(fnd_file.output,'<RET_DPN_X_VENTA_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_X_VENTA_ATTR>'); 
   dbms_output.put_line('<RET_DPN_X_VENTA_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_X_VENTA_ATTR>');
     *************************************/
   fnd_file.put_line(fnd_file.output,'<DPN>'||trim(to_char(let_depreciacion_tbl(idx).depn_del_ejercicio,gs_curr_format))||'</DPN>');
   fnd_file.put_line(fnd_file.output,'<ACUM_PERIOD>'||trim(to_char(let_depreciacion_tbl(idx).suma,gs_curr_format))||'</ACUM_PERIOD>');
   fnd_file.put_line(fnd_file.output,'<ACUM_ANUAL>'||trim(to_char(let_depreciacion_tbl(idx).saldo_final,gs_curr_format))||'</ACUM_ANUAL>');
   fnd_file.put_line(fnd_file.output,'</COLUMNAS>');  
  end loop;
  
  fnd_file.put_line(fnd_file.output,'<AGRUPADO>'||let_dpn_subtotal_rec.agrupado||'</AGRUPADO>');
  fnd_file.put_line(fnd_file.output,'<SUB_AAA>'||trim(to_char(let_dpn_subtotal_rec.saldo_inicial,gs_curr_format))||'</SUB_AAA>');
  fnd_file.put_line(fnd_file.output,'<SUB_DEB_AC>'||trim(to_char(let_dpn_subtotal_rec.ad_altas,gs_curr_format))||'</SUB_DEB_AC>');
  fnd_file.put_line(fnd_file.output,'<SUB_CRED>'||trim(to_char(let_dpn_subtotal_rec.ad_dism_inversa,gs_curr_format))||'</SUB_CRED>');
  fnd_file.put_line(fnd_file.output,'<SUB_AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_dpn_subtotal_rec.ad_transferencia,gs_curr_format))||'</SUB_AD_TRANSFERENCIA_ATTR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_MOI_SIN_INGR>'||trim(to_char(let_dpn_subtotal_rec.ret_moi_sin_ingr,gs_curr_format))||'</SUB_RET_MOI_SIN_INGR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_MOI_X_VENTA>'||trim(to_char(let_dpn_subtotal_rec.ret_moi_x_venta,gs_curr_format))||'</SUB_RET_MOI_X_VENTA>'); 
  
  
  
  
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  fnd_file.put_line(fnd_file.output,'<SUB_RET_DPN_SIN_INGR>'||trim(to_char(let_dpn_subtotal_rec.ret_dpn_sin_ingr,gs_curr_format))||'</SUB_RET_DPN_SIN_INGR>'); 
  fnd_file.put_line(fnd_file.output,'<SUB_RET_DPN_X_VENTA>'||trim(to_char(let_dpn_subtotal_rec.ret_dpn_x_venta,gs_curr_format))||'</SUB_RET_DPN_X_VENTA>'); 
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  
  
  
  fnd_file.put_line(fnd_file.output,'<SUB_DPN>'||trim(to_char(let_dpn_subtotal_rec.depn_del_ejercicio,gs_curr_format))||'</SUB_DPN>');
  fnd_file.put_line(fnd_file.output,'<SUB_AP>'||trim(to_char(let_dpn_subtotal_rec.suma,gs_curr_format))||'</SUB_AP>');
  fnd_file.put_line(fnd_file.output,'<SUB_AA>'||trim(to_char(let_dpn_subtotal_rec.saldo_final,gs_curr_format))||'</SUB_AA>');
  
  fnd_file.put_line(fnd_file.output,'</RUBRO>');  
  
   end if; /** END   if 5 = ln_stop_step4 then  **/
  end if; /** END  if let_depreciacion_tbl.count > 0 then   **/
   
  
  fnd_file.put_line(fnd_file.output,'<TOT_AAA>'||trim(to_char(let_subtotal_vnl_rec.saldo_inicial,gs_curr_format))||'</TOT_AAA>');
  fnd_file.put_line(fnd_file.output,'<TOT_DEB_AC>'||trim(to_char(let_subtotal_vnl_rec.ad_altas,gs_curr_format))||'</TOT_DEB_AC>');
  fnd_file.put_line(fnd_file.output,'<TOT_CRED>'||trim(to_char(let_subtotal_vnl_rec.ad_dism_inversa,gs_curr_format))||'</TOT_CRED>');
  fnd_file.put_line(fnd_file.output,'<TOT_TRANSFERENCIA>'||trim(to_char(let_subtotal_vnl_rec.ad_transferencia,gs_curr_format))||'</TOT_TRANSFERENCIA>');
  fnd_file.put_line(fnd_file.output,'<TOT_BAJA_SIN_INGR>'||trim(to_char(let_subtotal_vnl_rec.ret_moi_sin_ingr,gs_curr_format))||'</TOT_BAJA_SIN_INGR>');
  fnd_file.put_line(fnd_file.output,'<TOT_BAJA_X_VENTA>'||trim(to_char(let_subtotal_vnl_rec.ret_moi_x_venta,gs_curr_format))||'</TOT_BAJA_X_VENTA>');
  
  
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  fnd_file.put_line(fnd_file.output,'<TOT_DPN_SIN_INGR>'||trim(to_char(let_subtotal_vnl_rec.ret_dpn_sin_ingr,gs_curr_format))||'</TOT_DPN_SIN_INGR>');
  fnd_file.put_line(fnd_file.output,'<TOT_DPN_X_VENTA>'||trim(to_char(let_subtotal_vnl_rec.ret_dpn_x_venta,gs_curr_format))||'</TOT_DPN_X_VENTA>');
    /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/

  
  
  
  fnd_file.put_line(fnd_file.output,'<TOT_DPN>'||trim(to_char(let_subtotal_vnl_rec.depn_del_ejercicio,gs_curr_format))||'</TOT_DPN>');
  fnd_file.put_line(fnd_file.output,'<TOT_AP>'||trim(to_char(let_subtotal_vnl_rec.suma,gs_curr_format))||'</TOT_AP>');
  fnd_file.put_line(fnd_file.output,'<TOT_AA>'||trim(to_char(let_subtotal_vnl_rec.saldo_final,gs_curr_format))||'</TOT_AA>');
  
  
  end if; /** END if 2 = ln_stop_step1 then  **/
  
  
 exception when others then 
  fnd_file.put_line(fnd_file.log,'Exception print_op_men:'||sqlerrm||' ,'||sqlcode);
  
  pso_errmsg := 'Exception print_op_men:'||sqlerrm||' ,'||sqlcode; 
  pso_errcod := '2'; 
  
 end print_op_men; 
 
 
 procedure get_op_men(pso_errmsg           out varchar2 
                     ,pso_errcod           out varchar2
                     ,pti_tt_by_rubro_rec  in  t_by_rubro_rec
                     ,pcio_xml             in out clob
                      ) is 
 
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
                      
 begin 
 
 
 
  if 1 = ln_stop_step1 then 
  pso_errmsg := null; 
  pso_errcod := '0'; 
  
  
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
   
   pcio_xml := pcio_xml||'<RUBRO>'; 
  
   for idx in let_inversion_tbl.first .. let_inversion_tbl.last loop  
   pcio_xml := pcio_xml||'<COLUMNAS>'; 
   pcio_xml := pcio_xml||'<INF_RUBRO>'||let_inversion_tbl(idx).rubro||'</INF_RUBRO>';  
   
   pcio_xml := pcio_xml||'<ID_RUBRO>'||let_inversion_tbl(idx).num_rubro||'</ID_RUBRO>';
   pcio_xml := pcio_xml||'<CUENTA>'||let_inversion_tbl(idx).cuenta||'-'||let_inversion_tbl(idx).subcuenta||'</CUENTA>'; 
   pcio_xml := pcio_xml||'<CONCEPTO>'||let_inversion_tbl(idx).concepto||'</CONCEPTO>';    
   pcio_xml := pcio_xml||'<AA_PAS>'||trim(to_char(let_inversion_tbl(idx).saldo_inicial,gs_curr_format))||'</AA_PAS>';  
   pcio_xml := pcio_xml||'<DEB_AC>'||trim(to_char(nvl(let_inversion_tbl(idx).ad_altas,0),gs_curr_format))||'</DEB_AC>';  
   pcio_xml := pcio_xml||'<CRED>'||trim(to_char(let_inversion_tbl(idx).ad_dism_inversa,gs_curr_format))||'</CRED>'; 
   pcio_xml := pcio_xml||'<AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_inversion_tbl(idx).ad_transferencia,gs_curr_format))||'</AD_TRANSFERENCIA_ATTR>'; 
   /** Se agregarn en un futuro no lejano **/
   pcio_xml := pcio_xml||'<RET_MOI_SIN_INGR_ATTR>'||trim(to_char(let_inversion_tbl(idx).ret_moi_sin_ingr,gs_curr_format))||'</RET_MOI_SIN_INGR_ATTR>'; 
   pcio_xml := pcio_xml||'<RET_MOI_X_VENTA_ATTR>'||trim(to_char(let_inversion_tbl(idx).ret_moi_x_venta,gs_curr_format))||'</RET_MOI_X_VENTA_ATTR>'; 
   pcio_xml := pcio_xml||'<RET_DPN_SIN_INGR_ATTR>'||trim(to_char(let_inversion_tbl(idx).ret_dpn_sin_ingr,gs_curr_format))||'</RET_DPN_SIN_INGR_ATTR>'; 
   pcio_xml := pcio_xml||'<RET_DPN_X_VENTA_ATTR>'||trim(to_char(let_inversion_tbl(idx).ret_dpn_x_venta,gs_curr_format))||'</RET_DPN_X_VENTA_ATTR>'; 
   pcio_xml := pcio_xml ||'<DPN>'||trim(to_char(let_inversion_tbl(idx).depn_del_ejercicio,gs_curr_format))||'</DPN>';
   pcio_xml := pcio_xml||'<ACUM_PERIOD>'||trim(to_char(let_inversion_tbl(idx).suma,gs_curr_format))||'</ACUM_PERIOD>';
   pcio_xml := pcio_xml||'<ACUM_ANUAL>'||trim(to_char(let_inversion_tbl(idx).saldo_final,gs_curr_format))||'</ACUM_ANUAL>';
   
   pcio_xml := pcio_xml||'</COLUMNAS>'; 
   
  end loop;
  
  pcio_xml := pcio_xml||'<AGRUPADO>'||let_inv_subtotal_rec.agrupado||'</AGRUPADO>';
  pcio_xml := pcio_xml||'<SUB_AAA>'||trim(to_char(let_inv_subtotal_rec.saldo_inicial,gs_curr_format))||'</SUB_AAA>';
  pcio_xml := pcio_xml||'<SUB_DEB_AC>'||trim(to_char(let_inv_subtotal_rec.ad_altas,gs_curr_format))||'</SUB_DEB_AC>';
 pcio_xml := pcio_xml||'<SUB_CRED>'||trim(to_char(let_inv_subtotal_rec.ad_dism_inversa,gs_curr_format))||'</SUB_CRED>';
pcio_xml := pcio_xml||'<SUB_AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_inv_subtotal_rec.ad_transferencia,gs_curr_format))||'</SUB_AD_TRANSFERENCIA_ATTR>'; 
pcio_xml := pcio_xml||'<SUB_RET_MOI_SIN_INGR>'||trim(to_char(let_inv_subtotal_rec.ret_moi_sin_ingr,gs_curr_format))||'</SUB_RET_MOI_SIN_INGR>'; 
pcio_xml := pcio_xml||'<SUB_RET_MOI_X_VENTA>'||trim(to_char(let_inv_subtotal_rec.ret_moi_x_venta,gs_curr_format))||'</SUB_RET_MOI_X_VENTA>'; 
  
  
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  pcio_xml := pcio_xml||'<SUB_RET_DPN_SIN_INGR>'||trim(to_char(let_inv_subtotal_rec.ret_dpn_sin_ingr,gs_curr_format))||'</SUB_RET_DPN_SIN_INGR>'; 
  pcio_xml := pcio_xml||'<SUB_RET_DPN_X_VENTA>'||trim(to_char(let_inv_subtotal_rec.ret_dpn_x_venta,gs_curr_format))||'</SUB_RET_DPN_X_VENTA>'; 
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  
  
  
  pcio_xml := pcio_xml||'<SUB_DPN>'||trim(to_char(let_inv_subtotal_rec.depn_del_ejercicio,gs_curr_format))||'</SUB_DPN>';
  pcio_xml := pcio_xml||'<SUB_AP>'||trim(to_char(let_inv_subtotal_rec.suma,gs_curr_format))||'</SUB_AP>';
  pcio_xml := pcio_xml||'<SUB_AA>'||trim(to_char(let_inv_subtotal_rec.saldo_final,gs_curr_format))||'</SUB_AA>';
  
   pcio_xml := pcio_xml||'</RUBRO>'; 
  
   end if; /** END  if 3 = ln_stop_step2 then  **/
  
 
 end if; /** END  if let_inversion_tbl.count >0 then  **/
  
  
   if let_moneda_funcional_tbl.count >0 then 
  
   if 3 = ln_stop_step3 then 
  
  pcio_xml := pcio_xml||'<RUBRO>';  
  
  for idx in let_moneda_funcional_tbl.first .. let_moneda_funcional_tbl.last loop  
   pcio_xml := pcio_xml||'<COLUMNAS>';
   pcio_xml := pcio_xml||'<INF_RUBRO>'||let_moneda_funcional_tbl(idx).rubro||'</INF_RUBRO>';
   pcio_xml := pcio_xml||'<ID_RUBRO>'||let_moneda_funcional_tbl(idx).num_rubro||'</ID_RUBRO>';
   pcio_xml := pcio_xml||'<CUENTA>'||let_moneda_funcional_tbl(idx).cuenta||'-'||let_moneda_funcional_tbl(idx).subcuenta||'</CUENTA>'; 
   pcio_xml := pcio_xml||'<CONCEPTO>'||let_moneda_funcional_tbl(idx).concepto||'</CONCEPTO>';    
   pcio_xml := pcio_xml||'<AA_PAS>'||trim(to_char(let_moneda_funcional_tbl(idx).saldo_inicial,gs_curr_format))||'</AA_PAS>';  
   pcio_xml := pcio_xml||'<DEB_AC>'||trim(to_char(let_moneda_funcional_tbl(idx).ad_altas,gs_curr_format))||'</DEB_AC>';  
   pcio_xml := pcio_xml||'<CRED>'||trim(to_char(let_moneda_funcional_tbl(idx).ad_dism_inversa,gs_curr_format))||'</CRED>'; 
   pcio_xml := pcio_xml||'<AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ad_transferencia,gs_curr_format))||'</AD_TRANSFERENCIA_ATTR>'; 
   pcio_xml := pcio_xml||'<RET_MOI_SIN_INGR_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ret_moi_sin_ingr,gs_curr_format))||'</RET_MOI_SIN_INGR_ATTR>'; 
   pcio_xml := pcio_xml||'<RET_MOI_X_VENTA_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ret_moi_x_venta,gs_curr_format))||'</RET_MOI_X_VENTA_ATTR>'; 
   
   
   /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
   pcio_xml := pcio_xml||'<RET_DPN_SIN_INGR_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ret_dpn_sin_ingr,gs_curr_format))||'</RET_DPN_SIN_INGR_ATTR>'; 
  pcio_xml := pcio_xml||'<RET_DPN_X_VENTA_ATTR>'||trim(to_char(let_moneda_funcional_tbl(idx).ret_dpn_x_venta,gs_curr_format))||'</RET_DPN_X_VENTA_ATTR>'; 
     /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/

   
   
   
   
   pcio_xml := pcio_xml||'<DPN>'||trim(to_char(let_moneda_funcional_tbl(idx).depn_del_ejercicio,gs_curr_format))||'</DPN>';
   pcio_xml := pcio_xml||'<ACUM_PERIOD>'||trim(to_char(let_moneda_funcional_tbl(idx).suma,gs_curr_format))||'</ACUM_PERIOD>';
   pcio_xml := pcio_xml||'<ACUM_ANUAL>'||trim(to_char(let_moneda_funcional_tbl(idx).saldo_final,gs_curr_format))||'</ACUM_ANUAL>';
   pcio_xml := pcio_xml||'</COLUMNAS>';  
  end loop;
  
  pcio_xml := pcio_xml||'<AGRUPADO>'||let_mf_subtotal_rec .agrupado||'</AGRUPADO>';
  pcio_xml := pcio_xml||'<SUB_AAA>'||trim(to_char(let_mf_subtotal_rec .saldo_inicial,gs_curr_format))||'</SUB_AAA>';
  pcio_xml := pcio_xml||'<SUB_DEB_AC>'||trim(to_char(let_mf_subtotal_rec .ad_altas,gs_curr_format))||'</SUB_DEB_AC>';
  pcio_xml := pcio_xml||'<SUB_CRED>'||trim(to_char(let_mf_subtotal_rec .ad_dism_inversa,gs_curr_format))||'</SUB_CRED>';
  pcio_xml := pcio_xml||'<SUB_AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_mf_subtotal_rec.ad_transferencia,gs_curr_format))||'</SUB_AD_TRANSFERENCIA_ATTR>'; 
  pcio_xml := pcio_xml||'<SUB_RET_MOI_SIN_INGR>'||trim(to_char(let_mf_subtotal_rec.ret_moi_sin_ingr,gs_curr_format))||'</SUB_RET_MOI_SIN_INGR>'; 
  pcio_xml := pcio_xml||'<SUB_RET_MOI_X_VENTA>'||trim(to_char(let_mf_subtotal_rec.ret_moi_x_venta,gs_curr_format))||'</SUB_RET_MOI_X_VENTA>'; 
  
  
  
  
   /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  pcio_xml := pcio_xml||'<SUB_RET_DPN_SIN_INGR>'||trim(to_char(let_mf_subtotal_rec.ret_dpn_sin_ingr,gs_curr_format))||'</SUB_RET_DPN_SIN_INGR>'; 
  pcio_xml := pcio_xml||'<SUB_RET_DPN_X_VENTA>'||trim(to_char(let_mf_subtotal_rec.ret_dpn_x_venta,gs_curr_format))||'</SUB_RET_DPN_X_VENTA>'; 
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
 
  
  
  pcio_xml := pcio_xml||'<SUB_DPN>'||trim(to_char(let_mf_subtotal_rec.depn_del_ejercicio,gs_curr_format))||'</SUB_DPN>';
  pcio_xml := pcio_xml||'<SUB_AP>'||trim(to_char(let_mf_subtotal_rec.suma,gs_curr_format))||'</SUB_AP>';
  pcio_xml := pcio_xml||'<SUB_AA>'||trim(to_char(let_mf_subtotal_rec.saldo_final,gs_curr_format))||'</SUB_AA>';
  
  pcio_xml := pcio_xml||'</RUBRO>';  
  
   end if; /** END if 4 = ln_stop_step3 then  **/ 
  
  end if; /** END if let_moneda_funcional_tbl.count >0 then  **/
  
  
  /** ENTER DEPRECIACION **/
  
   fnd_file.put_line(fnd_file.log,'Count Dpn Table:'||let_depreciacion_tbl.count); 
   if let_depreciacion_tbl.count > 0 then  
   if 4 = ln_stop_step4 then 
 
  pcio_xml := pcio_xml ||'<RUBRO>';  
  
  for idx in let_depreciacion_tbl.first .. let_depreciacion_tbl.last loop  
   pcio_xml := pcio_xml||'<COLUMNAS>';
   pcio_xml := pcio_xml ||'<INF_RUBRO>'||let_depreciacion_tbl(idx).rubro||'</INF_RUBRO>';
   pcio_xml := pcio_xml ||'<ID_RUBRO>'||let_depreciacion_tbl(idx).num_rubro||'</ID_RUBRO>';
   pcio_xml := pcio_xml ||'<CUENTA>'||let_depreciacion_tbl(idx).cuenta||'-'||let_depreciacion_tbl(idx).subcuenta||'</CUENTA>'; 
  pcio_xml := pcio_xml||'<CONCEPTO>'||let_depreciacion_tbl(idx).concepto||'</CONCEPTO>';    
  pcio_xml := pcio_xml||'<AA_PAS>'||trim(to_char(let_depreciacion_tbl(idx).saldo_inicial,gs_curr_format))||'</AA_PAS>';  
   pcio_xml := pcio_xml||'<DEB_AC>'||trim(to_char(let_depreciacion_tbl(idx).ad_altas,gs_curr_format))||'</DEB_AC>';  
   pcio_xml := pcio_xml||'<CRED>'||trim(to_char(let_depreciacion_tbl(idx).ad_dism_inversa,gs_curr_format))||'</CRED>'; 
   pcio_xml := pcio_xml||'<AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ad_transferencia,gs_curr_format))||'</AD_TRANSFERENCIA_ATTR>'; 
   pcio_xml := pcio_xml||'<RET_MOI_SIN_INGR_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ret_moi_sin_ingr,gs_curr_format))||'</RET_MOI_SIN_INGR_ATTR>'; 
   pcio_xml := pcio_xml||'<RET_MOI_X_VENTA_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ret_moi_x_venta,gs_curr_format))||'</RET_MOI_X_VENTA_ATTR>'; 
   
   /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
   pcio_xml := pcio_xml||'<RET_DPN_SIN_INGR_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ret_dpn_sin_ingr,gs_curr_format))||'</RET_DPN_SIN_INGR_ATTR>'; 
   pcio_xml := pcio_xml||'<RET_DPN_X_VENTA_ATTR>'||trim(to_char(let_depreciacion_tbl(idx).ret_dpn_x_venta,gs_curr_format))||'</RET_DPN_X_VENTA_ATTR>'; 
     /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
     
     
     
     
     

   
   /** Se agregarn en un futuro no lejano **/
   /*****************************************
   fnd_file.put_line(fnd_file.output,'<RET_MOI_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_moi_sin_ingr||'</RET_MOI_SIN_INGR_ATTR>'); 
   dbms_output.put_line('<RET_MOI_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_moi_sin_ingr||'</RET_MOI_SIN_INGR_ATTR>');
   fnd_file.put_line(fnd_file.output,'<RET_MOI_X_VENTA_ATTR>'||let_depreciacion_tbl(idx).ad_transferencia||'</RET_MOI_X_VENTA_ATTR>'); 
   dbms_output.put_line('<RET_MOI_X_VENTA_ATTR>'||let_depreciacion_tbl(idx).ad_transferencia||'</RET_MOI_X_VENTA_ATTR>');
   fnd_file.put_line(fnd_file.output,'<RET_DPN_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_SIN_INGR_ATTR>'); 
   dbms_output.put_line('<RET_DPN_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_SIN_INGR_ATTR>');
   fnd_file.put_line(fnd_file.output,'<RET_DPN_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_SIN_INGR_ATTR>'); 
   dbms_output.put_line('<RET_DPN_SIN_INGR_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_SIN_INGR_ATTR>');
   fnd_file.put_line(fnd_file.output,'<RET_DPN_X_VENTA_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_X_VENTA_ATTR>'); 
   dbms_output.put_line('<RET_DPN_X_VENTA_ATTR>'||let_depreciacion_tbl(idx).ret_dpn_sin_ingr||'</RET_DPN_X_VENTA_ATTR>');
     *************************************/
   pcio_xml := pcio_xml||'<DPN>'||trim(to_char(let_depreciacion_tbl(idx).depn_del_ejercicio,gs_curr_format))||'</DPN>';
   pcio_xml := pcio_xml||'<ACUM_PERIOD>'||trim(to_char(let_depreciacion_tbl(idx).suma,gs_curr_format))||'</ACUM_PERIOD>';
   pcio_xml := pcio_xml||'<ACUM_ANUAL>'||trim(to_char(let_depreciacion_tbl(idx).saldo_final,gs_curr_format))||'</ACUM_ANUAL>';
   
    pcio_xml := pcio_xml||'</COLUMNAS>';
  
  end loop;
  
  pcio_xml := pcio_xml||'<AGRUPADO>'||let_dpn_subtotal_rec.agrupado||'</AGRUPADO>';
  pcio_xml := pcio_xml||'<SUB_AAA>'||trim(to_char(let_dpn_subtotal_rec.saldo_inicial,gs_curr_format))||'</SUB_AAA>';
  pcio_xml := pcio_xml||'<SUB_DEB_AC>'||trim(to_char(let_dpn_subtotal_rec.ad_altas,gs_curr_format))||'</SUB_DEB_AC>';
  pcio_xml := pcio_xml||'<SUB_CRED>'||trim(to_char(let_dpn_subtotal_rec.ad_dism_inversa,gs_curr_format))||'</SUB_CRED>';
  pcio_xml := pcio_xml||'<SUB_AD_TRANSFERENCIA_ATTR>'||trim(to_char(let_dpn_subtotal_rec.ad_transferencia,gs_curr_format))||'</SUB_AD_TRANSFERENCIA_ATTR>'; 
  pcio_xml := pcio_xml||'<SUB_RET_MOI_SIN_INGR>'||trim(to_char(let_dpn_subtotal_rec.ret_moi_sin_ingr,gs_curr_format))||'</SUB_RET_MOI_SIN_INGR>'; 
  pcio_xml := pcio_xml||'<SUB_RET_MOI_X_VENTA>'||trim(to_char(let_dpn_subtotal_rec.ret_moi_x_venta,gs_curr_format))||'</SUB_RET_MOI_X_VENTA>'; 
  
  
  
  
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  pcio_xml := pcio_xml||'<SUB_RET_DPN_SIN_INGR>'||trim(to_char(let_dpn_subtotal_rec.ret_dpn_sin_ingr,gs_curr_format))||'</SUB_RET_DPN_SIN_INGR>'; 
  pcio_xml := pcio_xml||'<SUB_RET_DPN_X_VENTA>'||trim(to_char(let_dpn_subtotal_rec.ret_dpn_x_venta,gs_curr_format))||'</SUB_RET_DPN_X_VENTA>'; 
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  
  
  
  pcio_xml := pcio_xml||'<SUB_DPN>'||trim(to_char(let_dpn_subtotal_rec.depn_del_ejercicio,gs_curr_format))||'</SUB_DPN>';
  pcio_xml := pcio_xml||'<SUB_AP>'||trim(to_char(let_dpn_subtotal_rec.suma,gs_curr_format))||'</SUB_AP>';
  pcio_xml := pcio_xml||'<SUB_AA>'||trim(to_char(let_dpn_subtotal_rec.saldo_final,gs_curr_format))||'</SUB_AA>';
  
  pcio_xml := pcio_xml ||'</RUBRO>';  
  
   end if; /** END   if 5 = ln_stop_step4 then  **/
  end if; /** END  if let_depreciacion_tbl.count > 0 then   **/
   
  
  pcio_xml := pcio_xml||'<TOT_AAA>'||trim(to_char(let_subtotal_vnl_rec.saldo_inicial,gs_curr_format))||'</TOT_AAA>';
  pcio_xml := pcio_xml||'<TOT_DEB_AC>'||trim(to_char(let_subtotal_vnl_rec.ad_altas,gs_curr_format))||'</TOT_DEB_AC>';
  pcio_xml := pcio_xml||'<TOT_CRED>'||trim(to_char(let_subtotal_vnl_rec.ad_dism_inversa,gs_curr_format))||'</TOT_CRED>';
  pcio_xml := pcio_xml||'<TOT_TRANSFERENCIA>'||trim(to_char(let_subtotal_vnl_rec.ad_transferencia,gs_curr_format))||'</TOT_TRANSFERENCIA>';
  pcio_xml := pcio_xml||'<TOT_BAJA_SIN_INGR>'||trim(to_char(let_subtotal_vnl_rec.ret_moi_sin_ingr,gs_curr_format))||'</TOT_BAJA_SIN_INGR>';
  pcio_xml := pcio_xml||'<TOT_BAJA_X_VENTA>'||trim(to_char(let_subtotal_vnl_rec.ret_moi_x_venta,gs_curr_format))||'</TOT_BAJA_X_VENTA>';
  
  
  /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/
  pcio_xml := pcio_xml||'<TOT_DPN_SIN_INGR>'||trim(to_char(let_subtotal_vnl_rec.ret_dpn_sin_ingr,gs_curr_format))||'</TOT_DPN_SIN_INGR>';
  pcio_xml := pcio_xml||'<TOT_DPN_X_VENTA>'||trim(to_char(let_subtotal_vnl_rec.ret_dpn_x_venta,gs_curr_format))||'</TOT_DPN_X_VENTA>';
    /**** codigo agregado para las columnas de depreciacion sin ingreso y por venta ****/

  
  
  
  pcio_xml := pcio_xml||'<TOT_DPN>'||trim(to_char(let_subtotal_vnl_rec.depn_del_ejercicio,gs_curr_format))||'</TOT_DPN>';
  pcio_xml := pcio_xml||'<TOT_AP>'||trim(to_char(let_subtotal_vnl_rec.suma,gs_curr_format))||'</TOT_AP>';
  pcio_xml := pcio_xml||'<TOT_AA>'||trim(to_char(let_subtotal_vnl_rec.saldo_final,gs_curr_format))||'</TOT_AA>';
  
  
  end if; /** END if 2 = ln_stop_step1 then  **/
  
  
 exception when others then 
  
  pso_errmsg := 'Exception print_op_men:'||sqlerrm||' ,'||sqlcode; 
  pso_errcod := '2'; 
  
 end get_op_men; 
 
                       
 

END xxgam_saf_op_men_pkg; 
/

