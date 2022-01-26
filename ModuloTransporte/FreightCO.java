/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxgam.oracle.apps.xbol.tm.freight.webui;

import java.sql.SQLException;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import xxgam.oracle.apps.xbol.tm.freight.server.FreightVOImpl;
import xxgam.oracle.apps.xbol.tm.freight.server.MaterialVOImpl;
import xxgam.oracle.apps.xbol.tm.freight.server.RequestAMImpl;
import xxgam.oracle.apps.xbol.tm.freight.server.RequestVOImpl;

/**
 * Controller for ...
 */
public class FreightCO extends OAControllerImpl
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
    System.out.println("Entrando a processRequest FreightPG");
    System.out.println(pageContext.getParameter("MFIdFreight"));
    System.out.println(pageContext.getParameter("RFIdRequest"));
    oracle.jbo.domain.Number iniRequest = new oracle.jbo.domain.Number(0);
    if(pageContext.getParameter("RFIdRequest")!=null)
    {
      try
      {
        iniRequest = new oracle.jbo.domain.Number(pageContext.getParameter("RFIdRequest"));
      } catch (SQLException e)
      {
        throw new OAException("SQL Error "+e, 
                              OAException.ERROR);
      }
    }
    RequestAMImpl am = (RequestAMImpl)pageContext.getApplicationModule(webBean);
    FreightVOImpl vo = am.getFreightVO1();
    String folio = null;
    String userId = String.valueOf(pageContext.getUserId());
    String userName = String.valueOf(pageContext.getUserName());
    String respId = String.valueOf(pageContext.getResponsibilityId());
    String respName = String.valueOf(pageContext.getResponsibilityName());
    String busG = String.valueOf(pageContext.getBusinessGroupId());
    String OpU = String.valueOf(pageContext.getProfile("ORG_ID"));
    System.out.println("User Id: "+userId);
    System.out.println("User Name: "+userName);
    System.out.println("Resp Id: "+respId);
    System.out.println("Resp Name: "+respName);
    System.out.println("Business Group: "+busG);
    System.out.println("Operating Unit: "+OpU);
    if(!pageContext.isFormSubmission() && null==vo.getCurrentRow())
    {
    folio=am.obtainFolio(userId,OpU);
    System.out.println("Folio: "+folio);
    am.iniFreightVO(folio,iniRequest);
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
     
    if ("FreightMaterial".equals(pageContext.getParameter(EVENT_PARAM)))
     {
      System.out.println(pageContext.getParameter("pIdFreight"));
      MaterialVOImpl vo = am.getMaterialVO1();
      vo.reset();
      am.saveFreightPG();
      pageContext.setForwardURL("OA.jsp?page=/xxgam/oracle/apps/xbol/tm/freight/webui/MaterialPG",
                                        null,
                                        OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                        null,                                                   
                                        null,
                                        true,                            
                                        OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                        OAWebBeanConstants.IGNORE_MESSAGES);
     } 
    
    if(pageContext.getParameter("NewStretch")!=null)
     {
       OAException descMesg = new OAException("Guardar", OAException.WARNING);
       OAException instrMesg = new OAException("Asegúrese de que la información de flete" +
       " y materiales del último tramo sea correcta. ¿Continuar?", OAException.INFORMATION);
       OADialogPage dialogPage = new OADialogPage(OAException.WARNING, descMesg, instrMesg, "", "");
       dialogPage.setOkButtonToPost(true);
       dialogPage.setNoButtonToPost(true);
       dialogPage.setPostToCallingPage(true);
       dialogPage.setOkButtonItemName("SaveYes");
       dialogPage.setNoButtonItemName("SaveNo");
       pageContext.redirectToDialogPage(dialogPage);
     }
       else if (pageContext.getParameter("SaveYes") != null) {
           am.createStretch(); 
           throw new OAException("Información guardada satisfactoriamente.", 
                                 OAException.CONFIRMATION);
       }
       else if (pageContext.getParameter("SaveNo") != null) {
           throw new OAException("Información sin guardar.", 
                               OAException.CONFIRMATION);
       } 
     
     if(pageContext.getParameter("Save")!=null)
     {
      am.saveFreightPG(); 
     }
     
    if ("editFPG".equals(pageContext.getParameter(EVENT_PARAM)))
    {
      System.out.println("Entrando en editar con parametro "+pageContext.getParameter("pIdFreightEdit"));
      am.setReadOnlyFreightPG(pageContext.getParameter("pIdFreightEdit"));
    }
    
  }

}
