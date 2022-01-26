The goal of this project was to develop a software that improved the management of the transport services hired by Aeroméxico by incorporating the creation of the
transport requests with complete detail. The given solution was the creation of multiple OAF pages (Oracle technology based in Java language) were the user could 
easily specify the materials to be transported, the date, the company to be hired for the service, etc. Those pages (FreightPG, MaterialPG, etc.) were built with View (%VOImpl%) 
and Entity Objects (%EOImpl%) that connected them to tables in the AMX database containing all the necessary information to build the request. Each page had its own controller 
(FreightCO, MaterialCO, etc.) i.e. the code that ruled their functionality.  
