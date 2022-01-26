package xxgam.oracle.apps.xbol.tm.freight.server;

import oracle.apps.fnd.framework.server.OAViewRowImpl;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;

import xxgam.oracle.apps.xbol.tm.freight.schema.MaterialEOImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class MaterialVORowImpl extends OAViewRowImpl
{
  public static final int IDMATERIAL = 0;
  public static final int IDFREIGHT = 1;
  public static final int IDREQUEST = 2;
  public static final int MATERIALNUM = 3;
  public static final int IDMATERIALTYPE = 4;
  public static final int MATERIALTYPE = 5;
  public static final int MATERIALDATE = 6;
  public static final int MATERIALTIME = 7;
  public static final int DISTRIBUTION = 8;
  public static final int IDLOADTYPE = 9;
  public static final int LOADTYPE = 10;
  public static final int IDDGR = 11;
  public static final int DGR = 12;
  public static final int IDDOCUMENT = 13;
  public static final int DOCUMENTDESCRIPTION = 14;
  public static final int NREFERENCE = 15;
  public static final int SHIPMENT = 16;
  public static final int ATTRIBUTE1 = 17;
  public static final int ATTRIBUTE2 = 18;
  public static final int ATTRIBUTE3 = 19;
  public static final int ATTRIBUTE4 = 20;
  public static final int ATTRIBUTE5 = 21;
  public static final int ATTRIBUTE6 = 22;
  public static final int ATTRIBUTE7 = 23;
  public static final int ATTRIBUTE8 = 24;
  public static final int ATTRIBUTE9 = 25;
  public static final int ATTRIBUTE10 = 26;
  public static final int LASTUPDATEDATE = 27;
  public static final int LASTUPDATEDBY = 28;
  public static final int CREATIONDATE = 29;
  public static final int CREATEDBY = 30;
  public static final int LASTUPDATELOGIN = 31;
  public static final int TOTALWEIGHT = 32;
  public static final int TOTALVOL = 33;
  public static final int IDLOADPRESENTATION = 34;
  public static final int LOADPRESENTATION = 35;
  public static final int WEIGHT = 36;
  public static final int WEIGHTUNITS = 37;
  public static final int UNITSNUMBER = 38;
  public static final int UNITSTYPE = 39;
  public static final int TOTALWEIGHTUNITS = 40;
  public static final int LENGHT = 41;
  public static final int LENGHTUNITS = 42;
  public static final int WIDTH = 43;
  public static final int WIDTHUNITS = 44;
  public static final int HEIGHT = 45;
  public static final int HEIGHTUNITS = 46;
  public static final int DETAILFLAG = 47;
  public static final int ISRECORDENABLED = 48;
  public static final int ISEDITENABLED = 49;

  /**This is the default constructor (do not remove)
   */
  public MaterialVORowImpl()
  {
  }

  /**Gets MaterialEO entity object.
   */
  public MaterialEOImpl getMaterialEO()
  {
    return (MaterialEOImpl)getEntity(0);
  }

  /**Gets the attribute value for ID_MATERIAL using the alias name IdMaterial
   */
  public Number getIdMaterial()
  {
    return (Number) getAttributeInternal(IDMATERIAL);
  }

  /**Sets <code>value</code> as attribute value for ID_MATERIAL using the alias name IdMaterial
   */
  public void setIdMaterial(Number value)
  {
    setAttributeInternal(IDMATERIAL, value);
  }

  /**Gets the attribute value for ID_FREIGHT using the alias name IdFreight
   */
  public Number getIdFreight()
  {
    return (Number) getAttributeInternal(IDFREIGHT);
  }

  /**Sets <code>value</code> as attribute value for ID_FREIGHT using the alias name IdFreight
   */
  public void setIdFreight(Number value)
  {
    setAttributeInternal(IDFREIGHT, value);
  }

  /**Gets the attribute value for ID_REQUEST using the alias name IdRequest
   */
  public Number getIdRequest()
  {
    return (Number) getAttributeInternal(IDREQUEST);
  }

  /**Sets <code>value</code> as attribute value for ID_REQUEST using the alias name IdRequest
   */
  public void setIdRequest(Number value)
  {
    setAttributeInternal(IDREQUEST, value);
  }

  /**Gets the attribute value for MATERIAL_NUM using the alias name MaterialNum
   */
  public Number getMaterialNum()
  {
    return (Number) getAttributeInternal(MATERIALNUM);
  }

  /**Sets <code>value</code> as attribute value for MATERIAL_NUM using the alias name MaterialNum
   */
  public void setMaterialNum(Number value)
  {
    setAttributeInternal(MATERIALNUM, value);
  }

  /**Gets the attribute value for ID_MATERIAL_TYPE using the alias name IdMaterialType
   */
  public Number getIdMaterialType()
  {
    return (Number) getAttributeInternal(IDMATERIALTYPE);
  }

  /**Sets <code>value</code> as attribute value for ID_MATERIAL_TYPE using the alias name IdMaterialType
   */
  public void setIdMaterialType(Number value)
  {
    setAttributeInternal(IDMATERIALTYPE, value);
  }

  /**Gets the attribute value for MATERIAL_TYPE using the alias name MaterialType
   */
  public String getMaterialType()
  {
    return (String) getAttributeInternal(MATERIALTYPE);
  }

  /**Sets <code>value</code> as attribute value for MATERIAL_TYPE using the alias name MaterialType
   */
  public void setMaterialType(String value)
  {
    setAttributeInternal(MATERIALTYPE, value);
  }

  /**Gets the attribute value for MATERIAL_DATE using the alias name MaterialDate
   */
  public Date getMaterialDate()
  {
    return (Date) getAttributeInternal(MATERIALDATE);
  }

  /**Sets <code>value</code> as attribute value for MATERIAL_DATE using the alias name MaterialDate
   */
  public void setMaterialDate(Date value)
  {
    setAttributeInternal(MATERIALDATE, value);
  }

  /**Gets the attribute value for MATERIAL_TIME using the alias name MaterialTime
   */
  public String getMaterialTime()
  {
    return (String) getAttributeInternal(MATERIALTIME);
  }

  /**Sets <code>value</code> as attribute value for MATERIAL_TIME using the alias name MaterialTime
   */
  public void setMaterialTime(String value)
  {
    setAttributeInternal(MATERIALTIME, value);
  }

  /**Gets the attribute value for DISTRIBUTION using the alias name Distribution
   */
  public Number getDistribution()
  {
    return (Number) getAttributeInternal(DISTRIBUTION);
  }

  /**Sets <code>value</code> as attribute value for DISTRIBUTION using the alias name Distribution
   */
  public void setDistribution(Number value)
  {
    setAttributeInternal(DISTRIBUTION, value);
  }

  /**Gets the attribute value for ID_LOAD_TYPE using the alias name IdLoadType
   */
  public Number getIdLoadType()
  {
    return (Number) getAttributeInternal(IDLOADTYPE);
  }

  /**Sets <code>value</code> as attribute value for ID_LOAD_TYPE using the alias name IdLoadType
   */
  public void setIdLoadType(Number value)
  {
    setAttributeInternal(IDLOADTYPE, value);
  }

  /**Gets the attribute value for LOAD_TYPE using the alias name LoadType
   */
  public String getLoadType()
  {
    return (String) getAttributeInternal(LOADTYPE);
  }

  /**Sets <code>value</code> as attribute value for LOAD_TYPE using the alias name LoadType
   */
  public void setLoadType(String value)
  {
    setAttributeInternal(LOADTYPE, value);
  }

  /**Gets the attribute value for ID_DGR using the alias name IdDgr
   */
  public Number getIdDgr()
  {
    return (Number) getAttributeInternal(IDDGR);
  }

  /**Sets <code>value</code> as attribute value for ID_DGR using the alias name IdDgr
   */
  public void setIdDgr(Number value)
  {
    setAttributeInternal(IDDGR, value);
  }

  /**Gets the attribute value for DGR using the alias name Dgr
   */
  public String getDgr()
  {
    return (String) getAttributeInternal(DGR);
  }

  /**Sets <code>value</code> as attribute value for DGR using the alias name Dgr
   */
  public void setDgr(String value)
  {
    setAttributeInternal(DGR, value);
  }

  /**Gets the attribute value for ID_DOCUMENT using the alias name IdDocument
   */
  public Number getIdDocument()
  {
    return (Number) getAttributeInternal(IDDOCUMENT);
  }

  /**Sets <code>value</code> as attribute value for ID_DOCUMENT using the alias name IdDocument
   */
  public void setIdDocument(Number value)
  {
    setAttributeInternal(IDDOCUMENT, value);
  }

  /**Gets the attribute value for DOCUMENT_DESCRIPTION using the alias name DocumentDescription
   */
  public String getDocumentDescription()
  {
    return (String) getAttributeInternal(DOCUMENTDESCRIPTION);
  }

  /**Sets <code>value</code> as attribute value for DOCUMENT_DESCRIPTION using the alias name DocumentDescription
   */
  public void setDocumentDescription(String value)
  {
    setAttributeInternal(DOCUMENTDESCRIPTION, value);
  }

  /**Gets the attribute value for N_REFERENCE using the alias name NReference
   */
  public String getNReference()
  {
    return (String) getAttributeInternal(NREFERENCE);
  }

  /**Sets <code>value</code> as attribute value for N_REFERENCE using the alias name NReference
   */
  public void setNReference(String value)
  {
    setAttributeInternal(NREFERENCE, value);
  }

  /**Gets the attribute value for SHIPMENT using the alias name Shipment
   */
  public String getShipment()
  {
    return (String) getAttributeInternal(SHIPMENT);
  }

  /**Sets <code>value</code> as attribute value for SHIPMENT using the alias name Shipment
   */
  public void setShipment(String value)
  {
    setAttributeInternal(SHIPMENT, value);
  }

  /**Gets the attribute value for ATTRIBUTE1 using the alias name Attribute1
   */
  public String getAttribute1()
  {
    return (String) getAttributeInternal(ATTRIBUTE1);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE1 using the alias name Attribute1
   */
  public void setAttribute1(String value)
  {
    setAttributeInternal(ATTRIBUTE1, value);
  }

  /**Gets the attribute value for ATTRIBUTE2 using the alias name Attribute2
   */
  public String getAttribute2()
  {
    return (String) getAttributeInternal(ATTRIBUTE2);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE2 using the alias name Attribute2
   */
  public void setAttribute2(String value)
  {
    setAttributeInternal(ATTRIBUTE2, value);
  }

  /**Gets the attribute value for ATTRIBUTE3 using the alias name Attribute3
   */
  public String getAttribute3()
  {
    return (String) getAttributeInternal(ATTRIBUTE3);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE3 using the alias name Attribute3
   */
  public void setAttribute3(String value)
  {
    setAttributeInternal(ATTRIBUTE3, value);
  }

  /**Gets the attribute value for ATTRIBUTE4 using the alias name Attribute4
   */
  public String getAttribute4()
  {
    return (String) getAttributeInternal(ATTRIBUTE4);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE4 using the alias name Attribute4
   */
  public void setAttribute4(String value)
  {
    setAttributeInternal(ATTRIBUTE4, value);
  }

  /**Gets the attribute value for ATTRIBUTE5 using the alias name Attribute5
   */
  public String getAttribute5()
  {
    return (String) getAttributeInternal(ATTRIBUTE5);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE5 using the alias name Attribute5
   */
  public void setAttribute5(String value)
  {
    setAttributeInternal(ATTRIBUTE5, value);
  }

  /**Gets the attribute value for ATTRIBUTE6 using the alias name Attribute6
   */
  public String getAttribute6()
  {
    return (String) getAttributeInternal(ATTRIBUTE6);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE6 using the alias name Attribute6
   */
  public void setAttribute6(String value)
  {
    setAttributeInternal(ATTRIBUTE6, value);
  }

  /**Gets the attribute value for ATTRIBUTE7 using the alias name Attribute7
   */
  public String getAttribute7()
  {
    return (String) getAttributeInternal(ATTRIBUTE7);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE7 using the alias name Attribute7
   */
  public void setAttribute7(String value)
  {
    setAttributeInternal(ATTRIBUTE7, value);
  }

  /**Gets the attribute value for ATTRIBUTE8 using the alias name Attribute8
   */
  public String getAttribute8()
  {
    return (String) getAttributeInternal(ATTRIBUTE8);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE8 using the alias name Attribute8
   */
  public void setAttribute8(String value)
  {
    setAttributeInternal(ATTRIBUTE8, value);
  }

  /**Gets the attribute value for ATTRIBUTE9 using the alias name Attribute9
   */
  public String getAttribute9()
  {
    return (String) getAttributeInternal(ATTRIBUTE9);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE9 using the alias name Attribute9
   */
  public void setAttribute9(String value)
  {
    setAttributeInternal(ATTRIBUTE9, value);
  }

  /**Gets the attribute value for ATTRIBUTE10 using the alias name Attribute10
   */
  public String getAttribute10()
  {
    return (String) getAttributeInternal(ATTRIBUTE10);
  }

  /**Sets <code>value</code> as attribute value for ATTRIBUTE10 using the alias name Attribute10
   */
  public void setAttribute10(String value)
  {
    setAttributeInternal(ATTRIBUTE10, value);
  }

  /**Gets the attribute value for LAST_UPDATE_DATE using the alias name LastUpdateDate
   */
  public Date getLastUpdateDate()
  {
    return (Date) getAttributeInternal(LASTUPDATEDATE);
  }

  /**Sets <code>value</code> as attribute value for LAST_UPDATE_DATE using the alias name LastUpdateDate
   */
  public void setLastUpdateDate(Date value)
  {
    setAttributeInternal(LASTUPDATEDATE, value);
  }

  /**Gets the attribute value for LAST_UPDATED_BY using the alias name LastUpdatedBy
   */
  public Number getLastUpdatedBy()
  {
    return (Number) getAttributeInternal(LASTUPDATEDBY);
  }

  /**Sets <code>value</code> as attribute value for LAST_UPDATED_BY using the alias name LastUpdatedBy
   */
  public void setLastUpdatedBy(Number value)
  {
    setAttributeInternal(LASTUPDATEDBY, value);
  }

  /**Gets the attribute value for CREATION_DATE using the alias name CreationDate
   */
  public Date getCreationDate()
  {
    return (Date) getAttributeInternal(CREATIONDATE);
  }

  /**Sets <code>value</code> as attribute value for CREATION_DATE using the alias name CreationDate
   */
  public void setCreationDate(Date value)
  {
    setAttributeInternal(CREATIONDATE, value);
  }

  /**Gets the attribute value for CREATED_BY using the alias name CreatedBy
   */
  public Number getCreatedBy()
  {
    return (Number) getAttributeInternal(CREATEDBY);
  }

  /**Sets <code>value</code> as attribute value for CREATED_BY using the alias name CreatedBy
   */
  public void setCreatedBy(Number value)
  {
    setAttributeInternal(CREATEDBY, value);
  }

  /**Gets the attribute value for LAST_UPDATE_LOGIN using the alias name LastUpdateLogin
   */
  public Number getLastUpdateLogin()
  {
    return (Number) getAttributeInternal(LASTUPDATELOGIN);
  }

  /**Sets <code>value</code> as attribute value for LAST_UPDATE_LOGIN using the alias name LastUpdateLogin
   */
  public void setLastUpdateLogin(Number value)
  {
    setAttributeInternal(LASTUPDATELOGIN, value);
  }

  /**Gets the attribute value for TOTAL_WEIGHT using the alias name TotalWeight
   */
  public Number getTotalWeight()
  {
    return (Number) getAttributeInternal(TOTALWEIGHT);
  }

  /**Sets <code>value</code> as attribute value for TOTAL_WEIGHT using the alias name TotalWeight
   */
  public void setTotalWeight(Number value)
  {
    setAttributeInternal(TOTALWEIGHT, value);
  }

  /**Gets the attribute value for TOTAL_VOL using the alias name TotalVol
   */
  public Number getTotalVol()
  {
    return (Number) getAttributeInternal(TOTALVOL);
  }

  /**Sets <code>value</code> as attribute value for TOTAL_VOL using the alias name TotalVol
   */
  public void setTotalVol(Number value)
  {
    setAttributeInternal(TOTALVOL, value);
  }

  /**Gets the attribute value for ID_LOAD_PRESENTATION using the alias name IdLoadPresentation
   */
  public Number getIdLoadPresentation()
  {
    return (Number) getAttributeInternal(IDLOADPRESENTATION);
  }

  /**Sets <code>value</code> as attribute value for ID_LOAD_PRESENTATION using the alias name IdLoadPresentation
   */
  public void setIdLoadPresentation(Number value)
  {
    setAttributeInternal(IDLOADPRESENTATION, value);
  }

  /**Gets the attribute value for LOAD_PRESENTATION using the alias name LoadPresentation
   */
  public String getLoadPresentation()
  {
    return (String) getAttributeInternal(LOADPRESENTATION);
  }

  /**Sets <code>value</code> as attribute value for LOAD_PRESENTATION using the alias name LoadPresentation
   */
  public void setLoadPresentation(String value)
  {
    setAttributeInternal(LOADPRESENTATION, value);
  }

  /**Gets the attribute value for WEIGHT using the alias name Weight
   */
  public Number getWeight()
  {
    return (Number) getAttributeInternal(WEIGHT);
  }

  /**Sets <code>value</code> as attribute value for WEIGHT using the alias name Weight
   */
  public void setWeight(Number value)
  {
    setAttributeInternal(WEIGHT, value);
  }

  /**Gets the attribute value for WEIGHT_UNITS using the alias name WeightUnits
   */
  public String getWeightUnits()
  {
    return (String) getAttributeInternal(WEIGHTUNITS);
  }

  /**Sets <code>value</code> as attribute value for WEIGHT_UNITS using the alias name WeightUnits
   */
  public void setWeightUnits(String value)
  {
    setAttributeInternal(WEIGHTUNITS, value);
  }

  /**Gets the attribute value for UNITS_NUMBER using the alias name UnitsNumber
   */
  public Number getUnitsNumber()
  {
    return (Number) getAttributeInternal(UNITSNUMBER);
  }

  /**Sets <code>value</code> as attribute value for UNITS_NUMBER using the alias name UnitsNumber
   */
  public void setUnitsNumber(Number value)
  {
    setAttributeInternal(UNITSNUMBER, value);
  }

  /**Gets the attribute value for UNITS_TYPE using the alias name UnitsType
   */
  public String getUnitsType()
  {
    return (String) getAttributeInternal(UNITSTYPE);
  }

  /**Sets <code>value</code> as attribute value for UNITS_TYPE using the alias name UnitsType
   */
  public void setUnitsType(String value)
  {
    setAttributeInternal(UNITSTYPE, value);
  }

  /**Gets the attribute value for TOTAL_WEIGHT_UNITS using the alias name TotalWeightUnits
   */
  public String getTotalWeightUnits()
  {
    return (String) getAttributeInternal(TOTALWEIGHTUNITS);
  }

  /**Sets <code>value</code> as attribute value for TOTAL_WEIGHT_UNITS using the alias name TotalWeightUnits
   */
  public void setTotalWeightUnits(String value)
  {
    setAttributeInternal(TOTALWEIGHTUNITS, value);
  }

  /**Gets the attribute value for LENGHT using the alias name Lenght
   */
  public Number getLenght()
  {
    return (Number) getAttributeInternal(LENGHT);
  }

  /**Sets <code>value</code> as attribute value for LENGHT using the alias name Lenght
   */
  public void setLenght(Number value)
  {
    setAttributeInternal(LENGHT, value);
  }

  /**Gets the attribute value for LENGHT_UNITS using the alias name LenghtUnits
   */
  public String getLenghtUnits()
  {
    return (String) getAttributeInternal(LENGHTUNITS);
  }

  /**Sets <code>value</code> as attribute value for LENGHT_UNITS using the alias name LenghtUnits
   */
  public void setLenghtUnits(String value)
  {
    setAttributeInternal(LENGHTUNITS, value);
  }

  /**Gets the attribute value for WIDTH using the alias name Width
   */
  public Number getWidth()
  {
    return (Number) getAttributeInternal(WIDTH);
  }

  /**Sets <code>value</code> as attribute value for WIDTH using the alias name Width
   */
  public void setWidth(Number value)
  {
    setAttributeInternal(WIDTH, value);
  }

  /**Gets the attribute value for WIDTH_UNITS using the alias name WidthUnits
   */
  public String getWidthUnits()
  {
    return (String) getAttributeInternal(WIDTHUNITS);
  }

  /**Sets <code>value</code> as attribute value for WIDTH_UNITS using the alias name WidthUnits
   */
  public void setWidthUnits(String value)
  {
    setAttributeInternal(WIDTHUNITS, value);
  }

  /**Gets the attribute value for HEIGHT using the alias name Height
   */
  public Number getHeight()
  {
    return (Number) getAttributeInternal(HEIGHT);
  }

  /**Sets <code>value</code> as attribute value for HEIGHT using the alias name Height
   */
  public void setHeight(Number value)
  {
    setAttributeInternal(HEIGHT, value);
  }

  /**Gets the attribute value for HEIGHT_UNITS using the alias name HeightUnits
   */
  public String getHeightUnits()
  {
    return (String) getAttributeInternal(HEIGHTUNITS);
  }

  /**Sets <code>value</code> as attribute value for HEIGHT_UNITS using the alias name HeightUnits
   */
  public void setHeightUnits(String value)
  {
    setAttributeInternal(HEIGHTUNITS, value);
  }

  /**getAttrInvokeAccessor: generated method. Do not modify.
   */
  protected Object getAttrInvokeAccessor(int index, 
                                         AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
    {
    case IDMATERIAL:
      return getIdMaterial();
    case IDFREIGHT:
      return getIdFreight();
    case IDREQUEST:
      return getIdRequest();
    case MATERIALNUM:
      return getMaterialNum();
    case IDMATERIALTYPE:
      return getIdMaterialType();
    case MATERIALTYPE:
      return getMaterialType();
    case MATERIALDATE:
      return getMaterialDate();
    case MATERIALTIME:
      return getMaterialTime();
    case DISTRIBUTION:
      return getDistribution();
    case IDLOADTYPE:
      return getIdLoadType();
    case LOADTYPE:
      return getLoadType();
    case IDDGR:
      return getIdDgr();
    case DGR:
      return getDgr();
    case IDDOCUMENT:
      return getIdDocument();
    case DOCUMENTDESCRIPTION:
      return getDocumentDescription();
    case NREFERENCE:
      return getNReference();
    case SHIPMENT:
      return getShipment();
    case ATTRIBUTE1:
      return getAttribute1();
    case ATTRIBUTE2:
      return getAttribute2();
    case ATTRIBUTE3:
      return getAttribute3();
    case ATTRIBUTE4:
      return getAttribute4();
    case ATTRIBUTE5:
      return getAttribute5();
    case ATTRIBUTE6:
      return getAttribute6();
    case ATTRIBUTE7:
      return getAttribute7();
    case ATTRIBUTE8:
      return getAttribute8();
    case ATTRIBUTE9:
      return getAttribute9();
    case ATTRIBUTE10:
      return getAttribute10();
    case LASTUPDATEDATE:
      return getLastUpdateDate();
    case LASTUPDATEDBY:
      return getLastUpdatedBy();
    case CREATIONDATE:
      return getCreationDate();
    case CREATEDBY:
      return getCreatedBy();
    case LASTUPDATELOGIN:
      return getLastUpdateLogin();
    case TOTALWEIGHT:
      return getTotalWeight();
    case TOTALVOL:
      return getTotalVol();
    case IDLOADPRESENTATION:
      return getIdLoadPresentation();
    case LOADPRESENTATION:
      return getLoadPresentation();
    case WEIGHT:
      return getWeight();
    case WEIGHTUNITS:
      return getWeightUnits();
    case UNITSNUMBER:
      return getUnitsNumber();
    case UNITSTYPE:
      return getUnitsType();
    case TOTALWEIGHTUNITS:
      return getTotalWeightUnits();
    case LENGHT:
      return getLenght();
    case LENGHTUNITS:
      return getLenghtUnits();
    case WIDTH:
      return getWidth();
    case WIDTHUNITS:
      return getWidthUnits();
    case HEIGHT:
      return getHeight();
    case HEIGHTUNITS:
      return getHeightUnits();
    case DETAILFLAG:
      return getDetailFlag();
    case ISRECORDENABLED:
      return getIsRecordEnabled();
    case ISEDITENABLED:
      return getIsEditEnabled();
    default:
      return super.getAttrInvokeAccessor(index, attrDef);
    }
  }

  /**setAttrInvokeAccessor: generated method. Do not modify.
   */
  protected void setAttrInvokeAccessor(int index, Object value, 
                                       AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
    {
    case IDMATERIAL:
      setIdMaterial((Number)value);
      return;
    case IDFREIGHT:
      setIdFreight((Number)value);
      return;
    case IDREQUEST:
      setIdRequest((Number)value);
      return;
    case MATERIALNUM:
      setMaterialNum((Number)value);
      return;
    case IDMATERIALTYPE:
      setIdMaterialType((Number)value);
      return;
    case MATERIALTYPE:
      setMaterialType((String)value);
      return;
    case MATERIALDATE:
      setMaterialDate((Date)value);
      return;
    case MATERIALTIME:
      setMaterialTime((String)value);
      return;
    case DISTRIBUTION:
      setDistribution((Number)value);
      return;
    case IDLOADTYPE:
      setIdLoadType((Number)value);
      return;
    case LOADTYPE:
      setLoadType((String)value);
      return;
    case IDDGR:
      setIdDgr((Number)value);
      return;
    case DGR:
      setDgr((String)value);
      return;
    case IDDOCUMENT:
      setIdDocument((Number)value);
      return;
    case DOCUMENTDESCRIPTION:
      setDocumentDescription((String)value);
      return;
    case NREFERENCE:
      setNReference((String)value);
      return;
    case SHIPMENT:
      setShipment((String)value);
      return;
    case ATTRIBUTE1:
      setAttribute1((String)value);
      return;
    case ATTRIBUTE2:
      setAttribute2((String)value);
      return;
    case ATTRIBUTE3:
      setAttribute3((String)value);
      return;
    case ATTRIBUTE4:
      setAttribute4((String)value);
      return;
    case ATTRIBUTE5:
      setAttribute5((String)value);
      return;
    case ATTRIBUTE6:
      setAttribute6((String)value);
      return;
    case ATTRIBUTE7:
      setAttribute7((String)value);
      return;
    case ATTRIBUTE8:
      setAttribute8((String)value);
      return;
    case ATTRIBUTE9:
      setAttribute9((String)value);
      return;
    case ATTRIBUTE10:
      setAttribute10((String)value);
      return;
    case LASTUPDATEDATE:
      setLastUpdateDate((Date)value);
      return;
    case LASTUPDATEDBY:
      setLastUpdatedBy((Number)value);
      return;
    case CREATIONDATE:
      setCreationDate((Date)value);
      return;
    case CREATEDBY:
      setCreatedBy((Number)value);
      return;
    case LASTUPDATELOGIN:
      setLastUpdateLogin((Number)value);
      return;
    case TOTALWEIGHT:
      setTotalWeight((Number)value);
      return;
    case TOTALVOL:
      setTotalVol((Number)value);
      return;
    case IDLOADPRESENTATION:
      setIdLoadPresentation((Number)value);
      return;
    case LOADPRESENTATION:
      setLoadPresentation((String)value);
      return;
    case WEIGHT:
      setWeight((Number)value);
      return;
    case WEIGHTUNITS:
      setWeightUnits((String)value);
      return;
    case UNITSNUMBER:
      setUnitsNumber((Number)value);
      return;
    case UNITSTYPE:
      setUnitsType((String)value);
      return;
    case TOTALWEIGHTUNITS:
      setTotalWeightUnits((String)value);
      return;
    case LENGHT:
      setLenght((Number)value);
      return;
    case LENGHTUNITS:
      setLenghtUnits((String)value);
      return;
    case WIDTH:
      setWidth((Number)value);
      return;
    case WIDTHUNITS:
      setWidthUnits((String)value);
      return;
    case HEIGHT:
      setHeight((Number)value);
      return;
    case HEIGHTUNITS:
      setHeightUnits((String)value);
      return;
    case DETAILFLAG:
      setDetailFlag((Boolean)value);
      return;
    case ISRECORDENABLED:
      setIsRecordEnabled((Boolean)value);
      return;
    case ISEDITENABLED:
      setIsEditEnabled((Boolean)value);
      return;
    default:
      super.setAttrInvokeAccessor(index, value, attrDef);
      return;
    }
  }


  /**Gets the attribute value for the calculated attribute DetailFlag
   */
  public Boolean getDetailFlag()
  {
    return (Boolean) getAttributeInternal(DETAILFLAG);
  }

  /**Sets <code>value</code> as the attribute value for the calculated attribute DetailFlag
   */
  public void setDetailFlag(Boolean value)
  {
    setAttributeInternal(DETAILFLAG, value);
  }

  /**Gets the attribute value for the calculated attribute IsRecordEnabled
   */
  public Boolean getIsRecordEnabled()
  {
    return (Boolean) getAttributeInternal(ISRECORDENABLED);
  }

  /**Sets <code>value</code> as the attribute value for the calculated attribute IsRecordEnabled
   */
  public void setIsRecordEnabled(Boolean value)
  {
    setAttributeInternal(ISRECORDENABLED, value);
  }

  /**Gets the attribute value for the calculated attribute IsEditEnabled
   */
  public Boolean getIsEditEnabled()
  {
    return (Boolean) getAttributeInternal(ISEDITENABLED);
  }

  /**Sets <code>value</code> as the attribute value for the calculated attribute IsEditEnabled
   */
  public void setIsEditEnabled(Boolean value)
  {
    setAttributeInternal(ISEDITENABLED, value);
  }
}
