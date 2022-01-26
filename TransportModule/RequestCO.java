/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxgam.oracle.apps.xbol.tm.freight.webui;

import java.awt.Window;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

import java.io.Serializable;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

import java.util.Date;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import javax.swing.JFrame;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageTextInputBean;

import oracle.cabo.ui.data.DataObject;

import oracle.jbo.domain.BlobDomain;

import oracle.jdbc.OracleCallableStatement;

import xxgam.oracle.apps.xbol.tm.freight.server.MaterialVOImpl;
import xxgam.oracle.apps.xbol.tm.freight.server.RequestAMImpl;
import xxgam.oracle.apps.xbol.tm.freight.server.RequestVOImpl;

/**
 * Controller for ...
 */
 

public class RequestCO extends OAControllerImpl
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
    RequestVOImpl vo = am.getRequestVO1();
    MaterialVOImpl vo2 = am.getMaterialVO1();
    System.out.println("Entrando a processRequest RequestPG");
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
    OAMessageStyledTextBean UserId = (OAMessageStyledTextBean)webBean.findChildRecursive("UsuarioId");
    UserId.setValue(pageContext, userId);
    if(!pageContext.isFormSubmission() && null==vo.getCurrentRow())
    {
    System.out.println("Carga Tab 1");
    am.createRecord(userId, OpU);
    DateFormat sdf = new SimpleDateFormat("HH:mm:ss");
    Date date = new Date();
    System.out.println(sdf.format(date));   
    String t=(sdf.format(date));
    System.out.println(t);
    OAMessageTextInputBean hora = (OAMessageTextInputBean)webBean.findChildRecursive("TActivacion");
    hora.setValue(pageContext,t);
    OAMessageStyledTextBean PT = (OAMessageStyledTextBean)webBean.findChildRecursive("TotalWeight");
    PT.setValue(pageContext,0);
    OAMessageStyledTextBean VT = (OAMessageStyledTextBean)webBean.findChildRecursive("TotalVolume");
    VT.setValue(pageContext,0);
    }
    if(!pageContext.isFormSubmission() && null==vo2 .getCurrentRow())
    {
    System.out.println("Carga Tab 2");
    am.invokeMethod("createRecord2");
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
    //OAApplicationModule am = pageContext.getApplicationModule(webBean);
    RequestAMImpl am = (RequestAMImpl)pageContext.getApplicationModule(webBean);
    if(pageContext.getParameter("Submit")!=null)
     {
      System.out.println("Entrando a Submit processFormRequest RequestPG");
      upLoadFile(pageContext,webBean);    
     }
    
      if ("download".equals(pageContext.getParameter(EVENT_PARAM)))
     {
      System.out.println("Entrando a download processFormRequest RequestPG");
      String Doc = pageContext.getParameter("Document");
      System.out.print("Doc: "+Doc);
      String File = pageContext.getParameter(Doc);
      String FileName;
      BlobDomain BlobFile = null;
      Serializable[] param = {File};
      BlobFile = (BlobDomain)am.invokeMethod("consultaBlob", param);
      FileName = (String)am.invokeMethod("consultaName", param);
      System.out.println("FileName: "+FileName);
      DataObject dataobject =  pageContext.getNamedDataObject("_SessionParameters");
      HttpServletResponse response =  (HttpServletResponse)dataobject.selectValue(null, "HttpServletResponse");
      ServletOutputStream servletoutputstream = null; 
      try
      {
        System.out.println("Paso 1");
        servletoutputstream = response.getOutputStream();
        System.out.println("Paso 2");
        response.setHeader("Content-Disposition", "attachment;filename="+FileName);
        System.out.println("Paso 3");
        response.setContentType("text/plain");
        //response.setContentType("application/pdf");
        System.out.println("Paso 4");
        int iLength = (int)(BlobFile.getLength());
        System.out.println("Paso 5");
        response.setContentLength(iLength);
        System.out.println("Paso 6");
        ServletOutputStream op = response.getOutputStream();
        System.out.println("Paso 7");
        op.write(BlobFile.getBytes(1, iLength)); 
        System.out.println("Paso 8");
        op.flush(); 
        System.out.println("Paso 9");
        op.close();
        System.out.println("Paso 10");
      }
      catch(Exception e)
      {
        response.setContentType("text/html");
        throw new OAException("Excepcion:"+e.getMessage(),OAException.ERROR);
      }
     }
    
    if(pageContext.getParameter("NuevoMaterial")!=null)
     {
       System.out.println("Entrando a NuevoMaterial processFormRequest RequestPG");
       OAException descMesg = new OAException("Guardar", OAException.WARNING);
       OAException instrMesg = new OAException("La información actual se guardará para poder" +
       " ingresar un nuevo material. ¿Continuar?", OAException.INFORMATION);
       OADialogPage dialogPage = new OADialogPage(OAException.WARNING, descMesg, instrMesg, "", "");
       dialogPage.setOkButtonToPost(true);
       dialogPage.setNoButtonToPost(true);
       dialogPage.setPostToCallingPage(true);
       dialogPage.setOkButtonItemName("SaveYes");
       dialogPage.setNoButtonItemName("SaveNo");
       pageContext.redirectToDialogPage(dialogPage);
     }
       else if (pageContext.getParameter("SaveYes") != null) {
           am.createMaterial(pageContext, webBean); 
           throw new OAException("Información guardada satisfactoriamente.", 
                                 OAException.CONFIRMATION);
       }
       else if (pageContext.getParameter("SaveNo") != null) {
           throw new OAException("Información sin guardar.", 
                               OAException.CONFIRMATION);
       }  
    
    if ("Editar".equals(pageContext.getParameter(EVENT_PARAM)))
    {
      System.out.println("Entrando en editar con parametro "+pageContext.getParameter("pIdMaterial"));
      am.Editar(pageContext.getParameter("pIdMaterial"));
    }
    
    if(pageContext.getParameter("Cancelar")!=null)
    {
      System.out.println("Entrando a Cancelar processFormRequest RequestPG");
      OAException descMesg = new OAException("Borrar Información", OAException.WARNING);
      OAException instrMesg = new OAException("La infomación actual se borrará" +
      " ¿Proceder?", OAException.INFORMATION);
      OADialogPage dialogPage = new OADialogPage(OAException.WARNING, descMesg, instrMesg, "", "");
      dialogPage.setOkButtonToPost(true);
      dialogPage.setNoButtonToPost(true);
      dialogPage.setPostToCallingPage(true);
      dialogPage.setOkButtonItemName("SaveYesCancel");
      dialogPage.setNoButtonItemName("SaveNoCancel");
      pageContext.redirectToDialogPage(dialogPage);
    }
    else if (pageContext.getParameter("SaveYesCancel") != null) { 
      am.invokeMethod("deleteRequest"); 
      System.out.println("System exit");
      System.exit(0);
    }
    else if (pageContext.getParameter("SaveNoCancel") != null) {
        throw new OAException("No se borró la información", 
                            OAException.CONFIRMATION);
    }  
    
    if(pageContext.getParameter("Guardar")!=null)
    {
      System.out.println("Entrando a Guardar processFormRequest RequestPG");
      am.save(pageContext, webBean);
    }
    
    if(pageContext.getParameter("NuevoFlete")!=null)
    {
      System.out.println("Entrando a NuevoFlete processFormRequest RequestPG");
      RequestVOImpl vo = am.getRequestVO1();
      vo.first().setAttribute("Status", "En proceso");
      vo.first().setAttribute("IdStatus", 2);
      am.save(pageContext, webBean);
      com.sun.java.util.collections.HashMap parameters = new com.sun.java.util.collections.HashMap();
      System.out.println("Flag 1");
      parameters.put("RFIdRequest",vo.first().getAttribute("IdRequest"));
      System.out.println("Flag 2");
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
    
  }

  public void upLoadFile(OAPageContext pageContext,OAWebBean webBean)
  {
    System.out.println("Entrando a Metodo upLoadFile RequestCO");
    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    String filePath = "D:\\Test"; 
    //String filePath = "/interface/j_aemx/DAEMXI/outgoing/";
    System.out.println("Default File Path---->"+filePath);

     String fileUrl = null;
     try
     {
       DataObject fileUploadData =  pageContext.getNamedDataObject("MessageFileUpload");
       if(fileUploadData!=null)
         {
              String uFileName = (String)fileUploadData.selectValue(null, "UPLOAD_FILE_NAME"); 
              String contentType = (String) fileUploadData.selectValue(null, "UPLOAD_FILE_MIME_TYPE");  
              System.out.println("User File Name---->"+uFileName);

              FileOutputStream output = null;
              InputStream input = null;
              
              BlobDomain uploadedByteStream = (BlobDomain)fileUploadData.selectValue(null, uFileName);
              System.out.println("uploadedByteStream---->"+uploadedByteStream);
                                     
              File file = new File("D:\\Test", uFileName);  
              //File file = new File("/interface/j_aemx/DAEMXI/outgoing/", uFileName);
              System.out.println("File output---->"+file);

              output = new FileOutputStream(file);

              System.out.println("output----->"+output);
              input = uploadedByteStream.getInputStream();
              
              System.out.println("input---->"+input);
              byte abyte0[] = new byte[0x19000];
              int i;
               
              while((i = input.read(abyte0)) > 0)
              output.write(abyte0, 0, i);

              output.close();
              input.close();
              
              //Termina guardado en directorio
              
              Number DocId;
              
              System.out.println("Archivo: "+uFileName);    
              Serializable[] param = {uFileName};
              DocId = (Number)am.invokeMethod("saveFile",param);
              OAMessageTextInputBean Doc1 = (OAMessageTextInputBean)webBean.findChildRecursive("Doc1");
              OAMessageTextInputBean Doc2 = (OAMessageTextInputBean)webBean.findChildRecursive("Doc2");
              OAMessageTextInputBean Doc3 = (OAMessageTextInputBean)webBean.findChildRecursive("Doc3");
              if(Doc1.getValue(pageContext) == null) 
                {
                  Doc1.setValue(pageContext,DocId);
                }
              else if(Doc2.getValue(pageContext) == null)
                {
                  Doc2.setValue(pageContext,DocId);
                }
              else if(Doc3.getValue(pageContext) == null)
                {
                  Doc3.setValue(pageContext,DocId);
                }
         }
     }
    catch(Exception ex)
     {
      throw new OAException(ex.getMessage(), OAException.ERROR);
     }    
  }
  
  

}

