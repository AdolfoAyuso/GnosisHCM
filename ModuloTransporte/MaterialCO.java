/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxgam.oracle.apps.xbol.tm.freight.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.server.OADBTransaction;

import xxgam.oracle.apps.xbol.tm.freight.server.MaterialVOImpl;
import xxgam.oracle.apps.xbol.tm.freight.server.RequestAMImpl;
import xxgam.oracle.apps.xbol.tm.freight.server.RequestVOImpl;

/**
 * Controller for ...
 */
public class MaterialCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header$";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);
    RequestAMImpl am = (RequestAMImpl)pageContext.getApplicationModule(webBean);
    MaterialVOImpl vo = am.getMaterialVO1();
    System.out.println("Entrando a processRequest MaterialPG");
    System.out.println(pageContext.getParameter("pIdFreight"));
    System.out.println(pageContext.getParameter("pIdRequest"));
    System.out.println(pageContext.getParameter("pIdStretch"));
    if(!pageContext.isFormSubmission() && null==vo.getCurrentRow())
    {
    am.iniMat(pageContext.getParameter("pIdRequest")
              ,pageContext.getParameter("pIdFreight")
              ,pageContext.getParameter("pIdStretch")
              ,pageContext.getParameter("pIdFolio"));
    }  
  }

  /**
   * Procedure to handle form submissions for form elements in
   * a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);
    RequestAMImpl am = (RequestAMImpl)pageContext.getApplicationModule(webBean);
    
    if(pageContext.getParameter("NuevoMaterial")!=null)
     {
       OAException descMesg = new OAException("Guardar", OAException.WARNING);
       OAException instrMesg = new OAException("La información actual se guardará para poder" +
       " ingresar un nuevo material. ¿Continuar?", OAException.INFORMATION);
       OADialogPage dialogPage = new OADialogPage(OAException.WARNING, descMesg, instrMesg, "", "");
       dialogPage.setOkButtonToPost(true);
       dialogPage.setNoButtonToPost(true);
       dialogPage.setPostToCallingPage(true);
       dialogPage.setOkButtonItemName("SaveYesNM");
       dialogPage.setNoButtonItemName("SaveNoNM");
       pageContext.redirectToDialogPage(dialogPage);
     }
       else if (pageContext.getParameter("SaveYesNM") != null) {
           am.NewMaterialPG(pageContext, webBean); 
           throw new OAException("Información guardada satisfactoriamente.", 
                                 OAException.CONFIRMATION);
       }
       else if (pageContext.getParameter("SaveNoNM") != null) {
           throw new OAException("Información sin guardar.", 
                               OAException.CONFIRMATION);
       }
    
    if(pageContext.getParameter("Guardar")!=null)
    {
      am.saveMaterialPG(pageContext, webBean);
    }
    
    if(pageContext.getParameter("Return")!=null)
     {
       MaterialVOImpl vo = am.getMaterialVO1();
       System.out.println(vo.getCurrentRow().getAttribute("IdFreight"));
       am.saveMaterialPG(pageContext, webBean);
       com.sun.java.util.collections.HashMap parameters = new com.sun.java.util.collections.HashMap();
       parameters.put("MFIdFreight",vo.getCurrentRow().getAttribute("IdFreight"));
       pageContext.setForwardURL("OA.jsp?page=/xxgam/oracle/apps/xbol/tm/freight/webui/FreightPG"
                                        ,null
                                        ,OAWebBeanConstants.KEEP_MENU_CONTEXT
                                        ,null
                                        ,parameters 
                                        ,true
                                        ,OAWebBeanConstants.ADD_BREAD_CRUMB_YES
                                        ,OAWebBeanConstants.IGNORE_MESSAGES
                                        );  
     }
     
    if ("editMPG".equals(pageContext.getParameter(EVENT_PARAM)))
    {
      System.out.println("Entrando en editar con parametro "+pageContext.getParameter("pIdMaterialEdit"));
      am.setReadOnlyMaterialPG(pageContext.getParameter("pIdMaterialEdit"));
    }
    
  }

}
