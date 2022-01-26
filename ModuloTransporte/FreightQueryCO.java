/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxgam.oracle.apps.xbol.tm.freight.webui;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Calendar;
import java.util.Date;

import java.util.GregorianCalendar;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.apps.fnd.framework.webui.beans.message.OAMessageDateFieldBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;

import oracle.apps.fnd.framework.webui.beans.message.OAMessageTextInputBean;

import xxgam.oracle.apps.xbol.tm.freight.server.RequestAMImpl;
import xxgam.oracle.apps.xbol.tm.freight.server.RequestVOImpl;

/**
 * Controller for ...
 */
public class FreightQueryCO extends OAControllerImpl
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
    System.out.println("Entrando a processRequest FreightQueryCO");
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
    System.out.println("Entrando a processFormRequest FreightQueryCO");
    OAMessageTextInputBean IdRequest = (OAMessageTextInputBean)webBean.findChildRecursive("IdRequestQ");
    OAMessageTextInputBean IdStatus = (OAMessageTextInputBean)webBean.findChildRecursive("IdStatusQ");
    OAMessageTextInputBean IdPriority = (OAMessageTextInputBean)webBean.findChildRecursive("IdPriorityQ");
    OAMessageTextInputBean IdFreightChar = (OAMessageTextInputBean)webBean.findChildRecursive("IdFreightCharQ");
    OAMessageTextInputBean IdStatusF = (OAMessageTextInputBean)webBean.findChildRecursive("IdStatusFQ");
    OAMessageTextInputBean PriorityCodeF = (OAMessageTextInputBean)webBean.findChildRecursive("PriorityCodeFQ");
    //OAMessageDateFieldBean CreationDate = (OAMessageDateFieldBean)webBean.findChildRecursive("CreationDateQ");
    OAMessageTextInputBean NumberQ = (OAMessageTextInputBean)webBean.findChildRecursive("NumberQ");
    OAMessageTextInputBean JobQ = (OAMessageTextInputBean)webBean.findChildRecursive("JobQ");
    System.out.println("Actual event "+pageContext.getParameter(EVENT_PARAM));
    if(pageContext.getParameter("RequestBtn")!=null)
    {
     System.out.println("Entrando en evento RequestBtn processFormRequest FreightQueryCO");
      if(IdRequest.getValue(pageContext)!=null)
      {System.out.println(IdRequest.getValue(pageContext).toString());}
      else
      {IdRequest.setValue(pageContext,"0");}
      System.out.println("Flag1");
      if(IdStatus.getValue(pageContext)!=null)
      {System.out.println(IdStatus.getValue(pageContext).toString());}
      else{IdStatus.setValue(pageContext,"0");}
      System.out.println("Flag2");
      if(IdPriority.getValue(pageContext)!=null)
      {System.out.println(IdPriority.getValue(pageContext).toString());}
      else
      {IdPriority.setValue(pageContext,"0");}
     System.out.println("Flag3");
     am.RequestQuery(IdRequest.getValue(pageContext).toString(), IdStatus.getValue(pageContext).toString()
                   , IdPriority.getValue(pageContext).toString()); 
    }
    if(pageContext.getParameter("FreightBtn")!=null)
    {
     System.out.println("Entrando en evento FreightBtn processFormRequest FreightQueryCO");
      if(IdFreightChar.getValue(pageContext)!=null)
      {System.out.println(IdFreightChar.getValue(pageContext).toString());}
      else
      {IdFreightChar.setValue(pageContext,"0");}
      System.out.println("Flag1");
      if(IdStatusF.getValue(pageContext)!=null)
      {System.out.println(IdStatusF.getValue(pageContext).toString());}
      else{IdStatusF.setValue(pageContext,"0");}
      System.out.println("Flag2");
      if(PriorityCodeF.getValue(pageContext)!=null)
      {System.out.println(PriorityCodeF.getValue(pageContext).toString());}
      else
      {PriorityCodeF.setValue(pageContext,"0");}
      System.out.println("Flag3 ");
      /*Fecha Creacion
      System.out.println("Fecha Creacion");
      Date Dataux = new Date();
      Calendar myCalendar = new GregorianCalendar(1900, 1, 1);
      Date myDate = myCalendar.getTime();
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
      Date dateWithoutTime;
      try
      {
        dateWithoutTime = sdf.parse(sdf.format(myDate));
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        dateWithoutTime = cal.getTime();
        System.out.println("Fecha "+dateWithoutTime.toString());
      } catch (ParseException e)
      {
        System.out.println(e);
      }
      System.out.println("Fin Fecha Creacion");
      if(CreationDate.getValue(pageContext)!=null)
      {System.out.println(CreationDate.getValue(pageContext).toString());
       Dataux = (Date)CreationDate.getValue(pageContext);}
      else
      {System.out.println("Sin cambios Dataux "+Dataux.toString());}
      Fin Fecha Creacion*/
      System.out.println("Flag4");
      if(NumberQ.getValue(pageContext)!=null)
      {System.out.println(IdStatusF.getValue(pageContext).toString());}
      else{NumberQ.setValue(pageContext,"0");}
      System.out.println("Flag5");
      if(JobQ.getValue(pageContext)!=null)
      {System.out.println(JobQ.getValue(pageContext).toString());}
      else
      {JobQ.setValue(pageContext,"0");}
      System.out.println("Flag6");
      am.FreightQuery(IdFreightChar.getValue(pageContext).toString()
                    , IdStatusF.getValue(pageContext).toString()
                    , PriorityCodeF.getValue(pageContext).toString()
                    //, Dataux.toString()
                    //, NumberQ.getValue(pageContext).toString()
                    , JobQ.getValue(pageContext).toString()); 
    }
  }

}
