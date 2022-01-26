El objetivo de este proyecto fue desarrollar un software que mejorase la gestión de los servicios de transporte contratados por Aeroméxico incorporando la creación de solicitudes de transporte con lujo de detalle. La solución dada fue la creación de múltiples páginas OAF (tecnología de Oracle basada en Java) donde el usuario pudiera especificar fácilmente
los materiales a transportarse, la fecha del traslado, la compañía a contratar para el servicio, etc. Dichas páginas (FreightPG, MaterialPG, etc.) fueron construidas con View (%VOImpl%) y Entity Objects (%EOImpl%) que las conectaban con tablas en la base de datos de AMX que contenían toda la información necesaria para la creación de la solicitud.
Cada página tenía su controlador (FreightCO, MaterialCO, etc.) es decir, el código que gobernaba su funcionamiento.

**************

The goal of this project was to develop a software that improved the management of the transport services hired by Aeroméxico by incorporating the creation of the
transport requests with complete detail. The given solution was the creation of multiple OAF pages (Oracle technology based in Java language) were the user could 
easily specify the materials to be transported, the date, the company to be hired for the service, etc. Those pages (FreightPG, MaterialPG, etc.) were built with View (%VOImpl%) 
and Entity Objects (%EOImpl%) that connected them to tables in the AMX database containing all the necessary information to build the request. Each page had its own controller 
(FreightCO, MaterialCO, etc.) i.e. the code that ruled their functionality.  
