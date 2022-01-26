CREATE OR REPLACE package body APPS.XXGAM_SAF_OM_MASTER_PKG as

PROCEDURE MAIN(pso_errmsg          OUT  VARCHAR2
             , pso_errcode         OUT  VARCHAR2
             , psi_operating_unit  IN   VARCHAR2
             , psi_periodo         IN   VARCHAR2
             , psi_divisa          IN   VARCHAR2
              ) IS

lS_ERRMSG VARCHAR2(32767);
lS_ERRCOD VARCHAR2(32767);

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

/**     Variable de moneda     **/
ls_divisa       varchar2(32767);

/**     Variable de unidad operativa        ***/
ls_unidad_operativa     varchar2(32767);




 ltt_by_rubro1_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro2_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro3_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec; 
 ltt_by_rubro4_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro5_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro6_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro7_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro8_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro9_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro10_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro11_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro12_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro13_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro14_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec; 
 ltt_by_rubro15_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;  
 
 ltt_by_rubro20_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;  
  
 le_main_exception                   exception;
 
 
 ln_flag_rub1             number :=9; /*1 */
 ln_flag_rub2             number :=9; /*2*/
 ln_flag_rub3             number :=9; /*3 */
 ln_flag_rub4             number :=9; /*4 */ 
 ln_flag_rub5             number :=9; /*5 */ 
 ln_flag_rub6             number :=9; /*6 */ 
 ln_flag_rub7             number :=9; /*7 */ 
 ln_flag_rub8             number :=9; /*8*/
 ln_flag_rub9             number :=9; /*9 */ 
 ln_flag_rub10            number :=9; /*10 */ 
 ln_flag_rub11            number :=9; /*11*/ 
 ln_flag_rub12            number :=9; /*12*/ 
 ln_flag_rub13            number :=9; /*13*/ 
 ln_flag_rub14            number :=9; /*14*/ 
 ln_flag_rub15            number :=9; /*15*/ 
 
 sumaria_xml clob := NULL;
 period_start_date DATE := NULL;
 period_end_date DATE := NULL;
   
BEGIN

    lS_ERRMSG := NULL;
    lS_ERRCOD := '0';
    
    if psi_divisa = 'GAM_MXN' then
        ls_divisa := 'Pesos';
    else
        ls_divisa := 'Dolares';
    end if;         
    
    select lookup_code ||' - '||meaning UNI_OPER 
    into    ls_unidad_operativa
    from fnd_lookup_values
            where lookup_type = 'XXGAM_HR_CA_ORG_ACTIVAS'
            and language = 'ESA'
            and lookup_code = psi_operating_unit;    

      fnd_file.put_line(fnd_file.OUTPUT,'<XXGAM_SAF_OM_MASTER>'); 
     dbms_output.put_line('Comienza XXGAM_SAF_OM_MASTER_PKG.main ');
    fnd_file.put_line(fnd_file.OUTPUT,'<UNI_OPE>'||ls_unidad_operativa||'</UNI_OPE>');      
    fnd_file.put_line(fnd_file.OUTPUT,'<DIVISA>'||ls_divisa||'</DIVISA>');  
    fnd_file.put_line(fnd_file.OUTPUT,'<PERIODO>'||psi_periodo||'</PERIODO>'); 
    fnd_file.put_line(fnd_file.LOG,'Comienza XXGAM_SAF_OM_MASTER_PKG.main'); 
    fnd_file.put_line(fnd_file.LOG,'Parametros:'); 
    fnd_file.put_line(fnd_file.LOG,'Unidad Operativa:'||psi_operating_unit);
    fnd_file.put_line(fnd_file.LOG,'Periodo:'||psi_periodo);
    fnd_file.put_line(fnd_file.LOG,'Divisa:'||psi_divisa);
     if 1 = ln_flag_rub1 then 
     
       /** RUBRO 1 ***/  
        XXGAM_SAF_RUBRO1_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,psi_operating_unit   => psi_operating_unit
                                          ,psi_periodo          => psi_periodo
                                          ,psi_divisa              =>  psi_divisa
                                          ,pro_tt_by_rubro_rec  => ltt_by_rubro1_rec
                                          ); 
        /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
        
                
          fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod            => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec   => ltt_by_rubro1_rec
                                           ); 
          fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>');                                                          
        
        else 
         ls_errmsg := 'Fallo Ejecutar Rubro 01'; 
         raise le_main_exception;   
        end if;   
    
     end if; /**  if 1 = ln_flag_rub1 then  **/
     
     if 2 = ln_flag_rub2 then 
    
      /**** RUBRO 2***/
        XXGAM_SAF_RUB2_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,psi_operating_unit   => psi_operating_unit
                                          ,psi_periodo          => psi_periodo
                                          ,psi_divisa              =>  psi_divisa
                                          ,pro_tt_by_rubro_rec  => ltt_by_rubro2_rec
                                          ); 
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro2_rec
                                           ); 
         fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>');   
        else 
          ls_errmsg := 'Fallo Ejecutar Rubro 02.'||ls_errmsg; 
         raise le_main_exception;    
        end if;   
        
    
    end if; /** End if 2 = ln_flag_rub2 then  **/

      if 3 = ln_flag_rub3 then 
      
            /**** RUBRO 3 ****/                                 
         APPS.XXGAM_SAF_RUBRO3_V2_PKG.EXECUTE_R3 (pso_errmsg               => lS_ERRMSG
                                                   ,pso_errcod             => lS_ERRCOD
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => psi_periodo
                                                   ,psi_divisa            => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => ltt_by_rubro3_rec
                                                   );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro3_rec
                                           ); 
          fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 3'; 
         raise le_main_exception;   
           
        end if;     
      
      end if; /** End  if 3 = ln_flag_rub3 then **/
      
    
     if 4 = ln_flag_rub4 then 
     
        /**** RUBRO 4 ****/                                 
         APPS.XXGAM_SAF_RUBRO4_PKG.execute_rubro (pso_errmsg             => lS_ERRMSG
                                                 ,pso_errcod             => lS_ERRCOD
                                                 ,psi_operating_unit     => psi_operating_unit
                                                 ,psi_periodo            => psi_periodo
                                                 ,psi_divisa             => psi_divisa
                                                 ,pro_tt_by_rubro_rec    => ltt_by_rubro4_rec
                                                 );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro4_rec
                                           ); 
          fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 4'; 
         raise le_main_exception;   
           
        end if;
     
     end if;  /** END if 4 = ln_flag_rub4 then **/


    if 5 = ln_flag_rub5 then 
    
      /**** RUBRO 5***/
        XXGAM_SAF_RUB5_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,psi_operating_unit   => psi_operating_unit
                                          ,psi_periodo          => psi_periodo
                                          ,psi_divisa             => psi_divisa
                                          ,pro_tt_by_rubro_rec  => ltt_by_rubro5_rec
                                          ); 
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro5_rec
                                           ); 
         fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>');   
        else 
          ls_errmsg := 'Fallo Ejecutar Rubro 05'; 
         raise le_main_exception;    
        end if;   
        
    
    end if; /** End if 5 = ln_flag_rub5 then  **/
    
 if 6 = ln_flag_rub6 then 
      
            /**** RUBRO 6 ****/                                 
         APPS.XXGAM_SAF_RUBRO6_PKG.execute_rubro (pso_errmsg               => lS_ERRMSG
                                                   ,pso_errcod             => lS_ERRCOD
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => psi_periodo
                                                   ,psi_divisa               => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => ltt_by_rubro6_rec
                                                   );
        
                  fnd_file.put_line(fnd_file.LOG,'lS_ERRMSG: '|| lS_ERRMSG ); 
                  fnd_file.put_line(fnd_file.LOG,'lS_ERRCOD: '|| lS_ERRCOD ); 
                  
 
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro6_rec
                                           ); 
          fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 6:'||ls_errmsg;
          
         raise le_main_exception;   
           
        end if;     
      
      end if; /** End  if 6 = ln_flag_rub6 then **/

       
       
   
   if 7 = ln_flag_rub7 then 
   
     /**** RUBRO 7***/
    XXGAM_SAF_RUBRO_7_PKG.execute_rubro(x_errbuf          => lS_ERRMSG
                          ,x_retcode         => lS_ERRCOD
                          ,psi_operating_unit   =>  psi_operating_unit
                          ,P_periodo        => psi_periodo
                          ,pni_divisa       =>    psi_divisa
                          ,p_t_by_rubro_rec  => ltt_by_rubro7_rec
                                                                ); 
    
      /** Si no Hay Error Imprimir el rubro **/  
    if lS_ERRMSG is  null then 
     
     fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
      xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                       ,pso_errcod             => lS_ERRCOD
                                       ,pti_tt_by_rubro_rec => ltt_by_rubro7_rec
                                       ); 
     fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>');   
    else 
      ls_errmsg := 'Fallo Ejecutar Rubro 07'; 
     raise le_main_exception;    
    end if;   
    
   end if; /** END if 7 = ln_flag_rub7 then  **/
    

    
     if 8 = ln_flag_rub8 then 
     
        /**** RUBRO 8 ****/                                 
         XXGAM_SAF_RUBRO_8_PKG.execute_rubro(x_errbuf          => lS_ERRMSG
                          ,x_retcode         => lS_ERRCOD
                          ,psi_operating_unit   =>  psi_operating_unit
                          ,P_periodo       => psi_periodo
                          ,pni_divisa       =>    psi_divisa
                          ,p_t_by_rubro_rec  => ltt_by_rubro8_rec
                                                                ); 
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro8_rec
                                           ); 
          fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 8'; 
         raise le_main_exception;   
           
        end if;
     
     end if;  /** END if 8 = ln_flag_rub8 then **/

   
    
  if 9= ln_flag_rub9 then     
    /**** RUBRO 9 ****/                                 
     APPS.XXGAM_SAF_RUBRO9_PKG.EXECUTE_R9 (pso_errmsg             => lS_ERRMSG
                                               ,pso_errcod             => lS_ERRCOD
                                               ,psi_periodo            => psi_periodo
                                               ,psi_operating_unit   =>  psi_operating_unit
                                               ,psi_divisa               =>  psi_divisa
                                               ,pro_tt_by_rubro_rec    => ltt_by_rubro9_rec
                                               );
    
      /** Si no Hay Error Imprimir el rubro **/  
    if lS_ERRMSG is  null then 
     
     fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
      xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                       ,pso_errcod             => lS_ERRCOD
                                       ,pti_tt_by_rubro_rec => ltt_by_rubro9_rec
                                       ); 
      fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
      
    else 
    
     ls_errmsg := 'Fallo Ejecutar Rubro 9'; 
     raise le_main_exception;   
       
    end if;    
  end if; /** END if 9= ln_flag_rub9 then     **/
  
   if 10 = ln_flag_rub10 then 
    
      /**** RUBRO 10***/
        XXGAM_SAF_RUB10_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,psi_operating_unit   => psi_operating_unit
                                          ,psi_periodo          => psi_periodo
                                          ,psi_divisa             => psi_divisa
                                          ,pro_tt_by_rubro_rec  => ltt_by_rubro10_rec
                                          ); 
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro10_rec
                                           ); 
         fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>');   
        else 
          ls_errmsg := 'Fallo Ejecutar Rubro 10'||ls_errmsg; 
         raise le_main_exception;    
        end if;   
        
    
    end if; /** End if 10 = ln_flag_rub10 then  **/

--   
    if 11 = ln_flag_rub11 then 
     
        /**** RUBRO 11 ****/                                 
         APPS.XXGAM_SAF_RUBRO11_PKG.execute_rubro (pso_errmsg               =>  lS_ERRMSG
                                                   ,pso_errcod              =>  lS_ERRCOD
                                                   ,psi_operating_unit      =>  psi_operating_unit
                                                   ,psi_periodo             =>  psi_periodo
                                                   ,psi_divisa              =>  psi_divisa
                                                   ,pro_tt_by_rubro_rec     =>  ltt_by_rubro11_rec
                                                   );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro11_rec
                                           ); 
          fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro  11'; 
         raise le_main_exception;   
           
        end if;
     
     end if;  /** END if 11 = ln_flag_rub11 then **/

   
  
  if 12 = ln_flag_rub12 then 
  
        /**** RUBRO 12***/
    XXGAM_SAF_RUBRO12_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                      ,pso_errcod           => lS_ERRCOD
                                      ,psi_operating_unit   => psi_operating_unit
                                      ,psi_periodo         => psi_periodo
                                      ,psi_divisa            =>  psi_divisa
                                      ,pro_tt_by_rubro_rec  => ltt_by_rubro12_rec); 
    
      /** Si no Hay Error Imprimir el rubro **/  
    if lS_ERRMSG is  null then 
     
     fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
      xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                       ,pso_errcod             => lS_ERRCOD
                                       ,pti_tt_by_rubro_rec => ltt_by_rubro12_rec
                                       ); 
     fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>');   
    else 
      ls_errmsg := 'Fallo Ejecutar Rubro 12'; 
     raise le_main_exception;    
    end if;   
  end if; /** END  if 12 = ln_flag_rub12 then  **/  
  
  if 13 = ln_flag_rub13 then 
  
    /**** RUBRO 13 ****/                                 
     APPS.XXGAM_SAF_RUBRO13_V2_PKG.EXECUTE_R13 (pso_errmsg             => lS_ERRMSG
                                               ,pso_errcod             => lS_ERRCOD
                                               ,psi_operating_unit   => psi_operating_unit
                                               ,psi_periodo            => psi_periodo
                                               ,psi_divisa               => psi_divisa
                                               ,pro_tt_by_rubro_rec    => ltt_by_rubro13_rec
                                               );
    
      /** Si no Hay Error Imprimir el rubro **/  
    if lS_ERRMSG is  null then 
     
     fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
      xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                       ,pso_errcod             => lS_ERRCOD
                                       ,pti_tt_by_rubro_rec => ltt_by_rubro13_rec
                                       ); 
      fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
      
    else 
    
     ls_errmsg := 'Fallo Ejecutar Rubro 13'; 
     raise le_main_exception;   
       
    end if;             
     
  
  end if; /** END if 13 = ln_flag_rub13 then **/
                      
      if 14 = ln_flag_rub14 then 
      
            /**** RUBRO 14 ****/                                 
         APPS.XXGAM_SAF_RUBRO14_PKG.EXECUTE_R14 (pso_errmsg               => lS_ERRMSG
                                                   ,pso_errcod             => lS_ERRCOD
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => psi_periodo
                                                   ,psi_divisa               => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => ltt_by_rubro14_rec
                                                   );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro14_rec
                                           ); 
          fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 14'; 
         raise le_main_exception;   
           
        end if;     
      
      end if; /** End  if 14 = ln_flag_rub14 then **/
      
       if 14 = ln_flag_rub14 then 
      
            /**** RUBRO 15 ****/                                 
         APPS.XXGAM_SAF_RUBRO15_PKG.EXECUTE_R15 (pso_errmsg               => lS_ERRMSG
                                                   ,pso_errcod             => lS_ERRCOD
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => psi_periodo
                                                   ,psi_divisa               => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => ltt_by_rubro15_rec
                                                   );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         fnd_file.put_line(fnd_file.OUTPUT,'<RUBRO_TT>'); 
          xxgam_saf_op_men_pkg.print_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro15_rec
                                           ); 
          fnd_file.put_line(fnd_file.OUTPUT,'</RUBRO_TT>'); 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 15'; 
         raise le_main_exception;   
           
        end if;     
      
      end if; /** End  if 14 = ln_flag_rub15 then **/
            
      
      
      
      
       
      
  fnd_file.put_line(fnd_file.OUTPUT,'</XXGAM_SAF_OM_MASTER>');   
  
  --COMIENZA OBTENCION DE CLOB Y LLENADO DE TABLA
  
  XXGAM_SAF_OM_MASTER_PKG.OBTIENE_XML(pso_errmsg           => lS_ERRMSG
                                      ,pso_errcode         => lS_ERRCOD
                                      ,psi_operating_unit  => psi_operating_unit
                                      ,psi_periodo         => psi_periodo
                                      ,psi_divisa          => psi_divisa
                                      ,pco_xml             => sumaria_xml
                                      );
  
  SELECT DISTINCT START_DATE
  INTO period_start_date
  FROM GL_PERIODS
  WHERE PERIOD_NAME=psi_periodo
  AND PERIOD_SET_NAME='GAM';
  
  SELECT DISTINCT END_DATE
  INTO period_end_date
  FROM GL_PERIODS
  WHERE PERIOD_NAME=psi_periodo
  AND PERIOD_SET_NAME='GAM';
  
  INSERT INTO XXGAM_SAF_OM_TBL(SAF_OM_ID
                              ,OPERATING_UNIT
                              ,PERIOD
                              ,START_PERIOD
                              ,END_PERIOD
                              ,CURRENCY_CODE
                              ,XML_STRING
                              ,LAST_UPDATE_DATE
                              ,LAST_UPDATED_BY
                              ,LAST_UPDATE_LOGIN
                              ,CREATED_BY
                              ,CREATION_DATE
                              ,REQUEST_ID 
                              ,PROGRAM_APPLICATION_ID
                              ,PROGRAM_ID
                              ,PROGRAM_UPDATE_DATE
                              )
                       VALUES(XXGAM_SAF_OM_S.NEXTVAL
                             ,psi_operating_unit
                             ,psi_periodo
                             ,period_start_date
                             ,period_end_date
                             ,psi_divisa
                             ,sumaria_xml
                             ,SYSDATE
                             ,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1)
                             ,nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1)
                             ,nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1)
                             ,SYSDATE
                             ,nvl(TO_NUMBER(FND_PROFILE.VALUE('CONC_REQUEST_ID')),-1)
                             ,nvl(TO_NUMBER(FND_PROFILE.VALUE('CONC_PROGRAM_APPLICATION_ID')),-1)
                             ,nvl(TO_NUMBER(FND_PROFILE.VALUE('CONC_PROGRAM_ID')),-1)
                             ,SYSDATE
                             );
   
  
  
  fnd_file.put_line(fnd_file.log,'Finaliza XXGAM_SAF_OM_MASTER_PKG.main '); 
  
exception  when le_main_exception then 
 pso_errcode := '2'; 
 pso_errmsg  := ls_errmsg; 
 when others then 
     pso_errcode := '2'; 
     pso_errmsg  := 'Excepcion :'||sqlerrm||', '||sqlcode;
    fnd_file.put_line(fnd_file.log,'Excepcion :'||sqlerrm||', '||sqlcode);  
   dbms_output.put_line('Excepcion :' ||sqlerrm||', '||sqlcode); 

END MAIN;



PROCEDURE OBTIENE_XML(pso_errmsg          OUT  VARCHAR2
                     ,pso_errcode         OUT  VARCHAR2
                     ,psi_operating_unit  IN   VARCHAR2
                     ,psi_periodo         IN   VARCHAR2
                     ,psi_divisa          IN   VARCHAR2
                     ,pco_xml             out  clob
                       ) IS

lS_ERRMSG VARCHAR2(32767);
lS_ERRCOD VARCHAR2(32767);

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

/**     Variable de moneda     **/
ls_divisa       varchar2(32767);

/**     Variable de unidad operativa        ***/
ls_unidad_operativa     varchar2(32767);




 ltt_by_rubro1_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro2_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro3_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec; 
 ltt_by_rubro4_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro5_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro6_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro7_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro8_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro9_rec                   XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro10_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro11_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro12_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro13_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;
 ltt_by_rubro14_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec; 
 ltt_by_rubro15_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;  
 
 ltt_by_rubro20_rec                  XXGAM_SAF_OP_MEN_PKG.t_by_rubro_rec;  
  
 le_obt_xml_exception                   exception;
 
 
 ln_flag_rub1             number :=1; /*1 */
 ln_flag_rub2             number :=2; /*2*/
 ln_flag_rub3             number :=3; /*3 */
 ln_flag_rub4             number :=4; /*4 */ 
 ln_flag_rub5             number :=5; /*5 */ 
 ln_flag_rub6             number :=6; /*6 */ 
 ln_flag_rub7             number :=7; /*7 */ 
 ln_flag_rub8             number :=8; /*8*/
 ln_flag_rub9             number :=9; /*9 */ 
 ln_flag_rub10            number :=10; /*10 */ 
 ln_flag_rub11            number :=11; /*11*/ 
 ln_flag_rub12            number :=12; /*12*/ 
 ln_flag_rub13            number :=13; /*13*/ 
 ln_flag_rub14            number :=14; /*14*/ 
 ln_flag_rub15            number :=15; /*15*/ 
 
 
 
   
BEGIN

    lS_ERRMSG := NULL;
    lS_ERRCOD := '0';
    
    pco_xml := ''; 
    
    if psi_divisa = 'GAM_MXN' then
        ls_divisa := 'Pesos';
    else
        ls_divisa := 'Dolares';
    end if;         
    
    select lookup_code ||' - '||meaning UNI_OPER 
    into    ls_unidad_operativa
    from fnd_lookup_values
            where lookup_type = 'XXGAM_HR_CA_ORG_ACTIVAS'
            and language = 'ESA'
            and lookup_code = psi_operating_unit;    

    pco_xml := pco_xml||'<XXGAM_SAF_OM_MASTER>'; 
    pco_xml := pco_xml||'<UNI_OPE>'||ls_unidad_operativa||'</UNI_OPE>'; 
    pco_xml := pco_xml||'<DIVISA>'||ls_divisa||'</DIVISA>';
    pco_xml := pco_xml||'<PERIODO>'||psi_periodo||'</PERIODO>'; 
    
    
    
     if 1 = ln_flag_rub1 then 
     
       /** RUBRO 1 ***/  
        XXGAM_SAF_RUBRO1_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,psi_operating_unit   => psi_operating_unit
                                          ,psi_periodo          => psi_periodo
                                          ,psi_divisa           =>  psi_divisa
                                          ,pro_tt_by_rubro_rec  => ltt_by_rubro1_rec
                                          ); 
        /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
        
          pco_xml := pco_xml||'<RUBRO_TT>';       
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,pti_tt_by_rubro_rec  => ltt_by_rubro1_rec
                                          ,pcio_xml             => pco_xml
                                           ); 
          
          if lS_ERRMSG is not null then 
            ls_errmsg := 'Fallo Ejecutar y Obtener Estructura XML Rubro 01.'; 
            raise le_obt_xml_exception;  
          end if; 
                                           
          pco_xml := pco_xml||'</RUBRO_TT>';                                                        
        
        else 
         ls_errmsg := 'Fallo Ejecutar Rubro 01'; 
         raise le_obt_xml_exception;   
        end if;   
    
     end if; /**  if 1 = ln_flag_rub1 then  **/
     
     if 2 = ln_flag_rub2 then 
    
      /**** RUBRO 2***/
        XXGAM_SAF_RUB2_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,psi_operating_unit   => psi_operating_unit
                                          ,psi_periodo          => psi_periodo
                                          ,psi_divisa              =>  psi_divisa
                                          ,pro_tt_by_rubro_rec  => ltt_by_rubro2_rec
                                          ); 
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro2_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
          if lS_ERRMSG is not null then 
            ls_errmsg := 'Fallo Ejecutar y Obtener Estructura XML Rubro 02.'; 
            raise le_obt_xml_exception;  
          end if; 
                                            
         pco_xml := pco_xml||'</RUBRO_TT>';   
        else 
          ls_errmsg := 'Fallo Ejecutar Rubro 02.'||ls_errmsg; 
         raise le_obt_xml_exception;    
        end if;   
        
    
    end if; /** End if 2 = ln_flag_rub2 then  **/

      if 3 = ln_flag_rub3 then 
      
            /**** RUBRO 3 ****/                                 
         APPS.XXGAM_SAF_RUBRO3_V2_PKG.EXECUTE_R3 (pso_errmsg               => lS_ERRMSG
                                                   ,pso_errcod             => lS_ERRCOD
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => psi_periodo
                                                   ,psi_divisa            => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => ltt_by_rubro3_rec
                                                   );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro3_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
          pco_xml := pco_xml||'</RUBRO_TT>'; 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 3'; 
         raise le_obt_xml_exception;   
           
        end if;     
      
      end if; /** End  if 3 = ln_flag_rub3 then **/
      
    
     if 4 = ln_flag_rub4 then 
     
        /**** RUBRO 4 ****/                                 
         APPS.XXGAM_SAF_RUBRO4_PKG.execute_rubro (pso_errmsg             => lS_ERRMSG
                                                 ,pso_errcod             => lS_ERRCOD
                                                 ,psi_operating_unit     => psi_operating_unit
                                                 ,psi_periodo            => psi_periodo
                                                 ,psi_divisa             => psi_divisa
                                                 ,pro_tt_by_rubro_rec    => ltt_by_rubro4_rec
                                                 );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro4_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
          pco_xml := pco_xml||'</RUBRO_TT>'; 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 4'; 
         raise le_obt_xml_exception;   
           
        end if;
     
     end if;  /** END if 4 = ln_flag_rub4 then **/


    if 5 = ln_flag_rub5 then 
    
      /**** RUBRO 5***/
        XXGAM_SAF_RUB5_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,psi_operating_unit   => psi_operating_unit
                                          ,psi_periodo          => psi_periodo
                                          ,psi_divisa             => psi_divisa
                                          ,pro_tt_by_rubro_rec  => ltt_by_rubro5_rec
                                          ); 
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro5_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
         pco_xml := pco_xml||'</RUBRO_TT>';   
        else 
          ls_errmsg := 'Fallo Ejecutar Rubro 05'; 
         raise le_obt_xml_exception;    
        end if;   
        
    
    end if; /** End if 5 = ln_flag_rub5 then  **/
    
 if 6 = ln_flag_rub6 then 
      
            /**** RUBRO 6 ****/                                 
         APPS.XXGAM_SAF_RUBRO6_PKG.execute_rubro (pso_errmsg               => lS_ERRMSG
                                                   ,pso_errcod             => lS_ERRCOD
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => psi_periodo
                                                   ,psi_divisa               => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => ltt_by_rubro6_rec
                                                   );
        
                  fnd_file.put_line(fnd_file.LOG,'lS_ERRMSG: '|| lS_ERRMSG ); 
                  fnd_file.put_line(fnd_file.LOG,'lS_ERRCOD: '|| lS_ERRCOD ); 
                  
 
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro6_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
          pco_xml := pco_xml||'</RUBRO_TT>'; 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 6...oh nooooo';
          
         raise le_obt_xml_exception;   
           
        end if;     
      
      end if; /** End  if 6 = ln_flag_rub6 then **/

       
       
   
   if 7 = ln_flag_rub7 then 
   
     /**** RUBRO 7***/
    XXGAM_SAF_RUBRO_7_PKG.execute_rubro(x_errbuf          => lS_ERRMSG
                          ,x_retcode         => lS_ERRCOD
                          ,psi_operating_unit   =>  psi_operating_unit
                          ,P_periodo        => psi_periodo
                          ,pni_divisa       =>    psi_divisa
                          ,p_t_by_rubro_rec  => ltt_by_rubro7_rec
                                                                ); 
    
      /** Si no Hay Error Imprimir el rubro **/  
    if lS_ERRMSG is  null then 
     
     pco_xml := pco_xml||'<RUBRO_TT>'; 
      xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                       ,pso_errcod             => lS_ERRCOD
                                       ,pti_tt_by_rubro_rec => ltt_by_rubro7_rec
                                       ,pcio_xml             => pco_xml
                                       ); 
     pco_xml := pco_xml||'</RUBRO_TT>';   
    else 
      ls_errmsg := 'Fallo Ejecutar Rubro 07'; 
     raise le_obt_xml_exception;    
    end if;   
    
   end if; /** END if 7 = ln_flag_rub7 then  **/
    

    
     if 8 = ln_flag_rub8 then 
     
        /**** RUBRO 8 ****/                                 
         XXGAM_SAF_RUBRO_8_PKG.execute_rubro(x_errbuf          => lS_ERRMSG
                          ,x_retcode         => lS_ERRCOD
                          ,psi_operating_unit   =>  psi_operating_unit
                          ,P_periodo       => psi_periodo
                          ,pni_divisa       =>    psi_divisa
                          ,p_t_by_rubro_rec  => ltt_by_rubro8_rec
                                                                ); 
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro8_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
          pco_xml := pco_xml||'</RUBRO_TT>'; 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 8'; 
         raise le_obt_xml_exception;   
           
        end if;
     
     end if;  /** END if 8 = ln_flag_rub8 then **/

   
    
  if 9= ln_flag_rub9 then     
    /**** RUBRO 9 ****/                                 
     APPS.XXGAM_SAF_RUBRO9_PKG.EXECUTE_R9 (pso_errmsg             => lS_ERRMSG
                                               ,pso_errcod             => lS_ERRCOD
                                               ,psi_periodo            => psi_periodo
                                               ,psi_operating_unit   =>  psi_operating_unit
                                               ,psi_divisa               =>  psi_divisa
                                               ,pro_tt_by_rubro_rec    => ltt_by_rubro9_rec
                                               );
    
      /** Si no Hay Error Imprimir el rubro **/  
    if lS_ERRMSG is  null then 
     
     pco_xml := pco_xml||'<RUBRO_TT>'; 
      xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                       ,pso_errcod             => lS_ERRCOD
                                       ,pti_tt_by_rubro_rec => ltt_by_rubro9_rec
                                       ,pcio_xml             => pco_xml
                                       ); 
      pco_xml := pco_xml||'</RUBRO_TT>'; 
      
    else 
    
     ls_errmsg := 'Fallo Ejecutar Rubro 9'; 
     raise le_obt_xml_exception;   
       
    end if;    
  end if; /** END if 9= ln_flag_rub9 then     **/
  
   if 10 = ln_flag_rub10 then 
    
      /**** RUBRO 10***/
        XXGAM_SAF_RUB10_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                          ,pso_errcod           => lS_ERRCOD
                                          ,psi_operating_unit   => psi_operating_unit
                                          ,psi_periodo          => psi_periodo
                                          ,psi_divisa             => psi_divisa
                                          ,pro_tt_by_rubro_rec  => ltt_by_rubro10_rec
                                          ); 
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro10_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
         pco_xml := pco_xml||'</RUBRO_TT>';   
        else 
          ls_errmsg := 'Fallo Ejecutar Rubro 10'||ls_errmsg; 
         raise le_obt_xml_exception;    
        end if;   
        
    
    end if; /** End if 10 = ln_flag_rub10 then  **/

--   
    if 11 = ln_flag_rub11 then 
     
        /**** RUBRO 11 ****/                                 
         APPS.XXGAM_SAF_RUBRO11_PKG.execute_rubro (pso_errmsg               =>  lS_ERRMSG
                                                   ,pso_errcod              =>  lS_ERRCOD
                                                   ,psi_operating_unit      =>  psi_operating_unit
                                                   ,psi_periodo             =>  psi_periodo
                                                   ,psi_divisa              =>  psi_divisa
                                                   ,pro_tt_by_rubro_rec     =>  ltt_by_rubro11_rec
                                                   );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro11_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
          pco_xml := pco_xml||'</RUBRO_TT>'; 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro  11'; 
         raise le_obt_xml_exception;   
           
        end if;
     
     end if;  /** END if 11 = ln_flag_rub11 then **/

   
  
  if 12 = ln_flag_rub12 then 
  
        /**** RUBRO 12***/
    XXGAM_SAF_RUBRO12_PKG.execute_rubro(pso_errmsg           => lS_ERRMSG
                                      ,pso_errcod           => lS_ERRCOD
                                      ,psi_operating_unit   => psi_operating_unit
                                      ,psi_periodo         => psi_periodo
                                      ,psi_divisa            =>  psi_divisa
                                      ,pro_tt_by_rubro_rec  => ltt_by_rubro12_rec); 
    
      /** Si no Hay Error Imprimir el rubro **/  
    if lS_ERRMSG is  null then 
     
     pco_xml := pco_xml||'<RUBRO_TT>'; 
      xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                       ,pso_errcod             => lS_ERRCOD
                                       ,pti_tt_by_rubro_rec => ltt_by_rubro12_rec
                                       ,pcio_xml             => pco_xml
                                       ); 
     pco_xml := pco_xml||'</RUBRO_TT>';   
    else 
      ls_errmsg := 'Fallo Ejecutar Rubro 12'; 
     raise le_obt_xml_exception;    
    end if;   
  end if; /** END  if 12 = ln_flag_rub12 then  **/  
  
  if 13 = ln_flag_rub13 then 
  
    /**** RUBRO 13 ****/                                 
     APPS.XXGAM_SAF_RUBRO13_V2_PKG.EXECUTE_R13 (pso_errmsg             => lS_ERRMSG
                                               ,pso_errcod             => lS_ERRCOD
                                               ,psi_operating_unit   => psi_operating_unit
                                               ,psi_periodo            => psi_periodo
                                               ,psi_divisa               => psi_divisa
                                               ,pro_tt_by_rubro_rec    => ltt_by_rubro13_rec
                                               );
    
      /** Si no Hay Error Imprimir el rubro **/  
    if lS_ERRMSG is  null then 
     
     pco_xml := pco_xml||'<RUBRO_TT>'; 
      xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                       ,pso_errcod             => lS_ERRCOD
                                       ,pti_tt_by_rubro_rec => ltt_by_rubro13_rec
                                       ,pcio_xml             => pco_xml
                                       ); 
      pco_xml := pco_xml||'</RUBRO_TT>'; 
      
    else 
    
     ls_errmsg := 'Fallo Ejecutar Rubro 13'; 
     raise le_obt_xml_exception;   
       
    end if;             
     
  
  end if; /** END if 13 = ln_flag_rub13 then **/
                      
      if 14 = ln_flag_rub14 then 
      
            /**** RUBRO 14 ****/                                 
         APPS.XXGAM_SAF_RUBRO14_PKG.EXECUTE_R14 (pso_errmsg               => lS_ERRMSG
                                                   ,pso_errcod             => lS_ERRCOD
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => psi_periodo
                                                   ,psi_divisa               => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => ltt_by_rubro14_rec
                                                   );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro14_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
          pco_xml := pco_xml||'</RUBRO_TT>'; 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 14'; 
         raise le_obt_xml_exception;   
           
        end if;     
      
      end if; /** End  if 14 = ln_flag_rub14 then **/
      
       if 15 = ln_flag_rub15 then 
      
            /**** RUBRO 15 ****/                                 
         APPS.XXGAM_SAF_RUBRO15_PKG.EXECUTE_R15 (pso_errmsg               => lS_ERRMSG
                                                   ,pso_errcod             => lS_ERRCOD
                                                   ,psi_operating_unit     => psi_operating_unit
                                                   ,psi_periodo            => psi_periodo
                                                   ,psi_divisa               => psi_divisa
                                                   ,pro_tt_by_rubro_rec    => ltt_by_rubro15_rec
                                                   );
        
          /** Si no Hay Error Imprimir el rubro **/  
        if lS_ERRMSG is  null then 
         
         pco_xml := pco_xml||'<RUBRO_TT>'; 
          xxgam_saf_op_men_pkg.get_op_men(pso_errmsg            => lS_ERRMSG
                                           ,pso_errcod             => lS_ERRCOD
                                           ,pti_tt_by_rubro_rec => ltt_by_rubro15_rec
                                           ,pcio_xml             => pco_xml
                                           ); 
          pco_xml := pco_xml||'</RUBRO_TT>'; 
          
        else 
        
         ls_errmsg := 'Fallo Ejecutar Rubro 15'; 
         raise le_obt_xml_exception;   
           
        end if;     
      
      end if; /** End  if 15 = ln_flag_rub15 then **/
            
      
      
      
      
  pco_xml := pco_xml||'</XXGAM_SAF_OM_MASTER>'; 
  
exception  when le_obt_xml_exception then 
 pso_errcode := '2'; 
 pso_errmsg  := ls_errmsg; 
 when others then 
     pso_errcode := '2'; 
     pso_errmsg  := 'Excepcion :'||sqlerrm||', '||sqlcode;
   
END OBTIENE_XML;




END XXGAM_SAF_OM_MASTER_PKG; 
/

