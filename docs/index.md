# Fleet management system

# Overview and introduction
| ℹ️  |  This documentation is available online [here](https://sosnus.github.io/iap-client/). |
| --- | --- |
| ℹ️  |  Navigate to [Report 1](#report-1---feasibility-study-of-communication-between-systems) |
| ℹ️  |  Navigate to [Report 2](#report-2---establish-the-business-context-sketch-the-system-architecture-select-technology) |
| ℹ️  |  Navigate to [Report 3](#report-3---implementation-of-data-exchange-and-synchronization-headquartershq--officesbo) |
| ℹ️  |  Navigate to [Report 4](#report-4---performance-analysis-summary-and-conclusions-of-the-project) |

## Team

* Monika Rosa 239113
* Godfrey Mghase 239195
* Stanisław Puławski 239111
* Wiktor Muraszko 239109

## Description
The main objective of this project is to create a IT System for managing car fleet for the company, which consists of a headquarter and few branch offices located in different cities (Lodz, Warsaw, Cracow). Our solution connects the information systems of company's headquarters and its branches and allows enterprise to manage their car fleet. We have prepared working Web Service and Flutter Android client.

### **Repositories**
* Backend HQ repository [here](https://github.com/Wredter/IAP_project_1).
* Backend BO repository [here](https://github.com/muga01/IAP_project_2).
* Frontend repository [here](https://github.com/sosnus/apiconsument).

Documentation, scripts (and special frontend for 1st repo) [here](https://github.com/sosnus/iap-client)

## Technology stack

* Database
    * MySQL `MySQL Server 8.0.23-1debian10`
* Backend
    * Java Spring `Spring Boot (v2.4.3)`
* Frontend
      * Flutter `Flutter 2.2.2`
        * Android [Flutter Android](https://img.shields.io/badge/Android-yes-green)
        * Web [Flutter Web](https://img.shields.io/badge/Web-yes-green)
        * Web container [Flutter Web container](https://img.shields.io/badge/Web%20container-not%20yet-red)

### Production deployment
#### Production deployment links

* [HQ Warsaw office](https://iap-warsaw-hq.azurewebsites.net/)
* [BO Lodz office](https://iap-lodz-bo.azurewebsites.net/)

Backend containers are hosted on ASP (App Service Plan) with 28 other applications. ASP based on tier B2 and have: 3.5GB RAM and 2vCPU cores 

Databases containers are hosted on Azure Virtual Machine with a lot of others containers and services. VM size: Standard B1ms 1vCPU, 2GB RAM. Containers are separated and are ready to migration.

## Deployment diagram
![hqmodel](./deployment-diagram-28-06-2021.png)

When developer build and push image, webhooks will deploy container at ASP.

```bash
docker login sosnuscontainers.azurecr.io
# login: ********
# password: *********

docker build -t sosnuscontainers.azurecr.io/iap-warsaw-hq .
docker push sosnuscontainers.azurecr.io/iap-warsaw-hq

docker build -t sosnuscontainers.azurecr.io/iap-lodz-bo .
docker push sosnuscontainers.azurecr.io/iap-lodz-bo

docker build -t sosnuscontainers.azurecr.io/iap-cracow-bo .
docker push sosnuscontainers.azurecr.io/iap-cracow-bo

```

# Report 1 - Feasibility study of communication between systems

| ℹ️  |  the purpose of the first report is presentation connection between database, backend and frontend applications |
| --- | --- |


First, test deploy consist of 3 parts:
* MySQL database
* Spring boot backend service
* Flutter Android client

#### test deployment

For communication test purpouse, database and backend was deployed on docker containers, on the same Virtual Machine. VM size: Standard B1ms 1vCPU, 2GB RAM
* Backend address [here](http://s-vm.northeurope.cloudapp.azure.com:8081/)
* Database address [here](http://s-vm.northeurope.cloudapp.azure.com:3306/)


Before container deployment, it is necessary to enable new firewall rules:
```bash
ufw allow 22
ufw allow 3306
ufw allow 8081
ufw reload
```

## Database - deploy and test

For database deployment, we use simple bash script to run new docker container from Docker Hub

```bash

docker run --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql

```

We create first sql schema for this project using dbdiagram.io tool. Probably we will have some changes here in the future. Online documentation for our schema is [here]( https://dbdiagram.io/d/6053d308ecb54e10c33c2951) 

![DBeaver](./img/db-schema.png)

 

Next we create new database users to enable easy synchronous access for the rest of the team members. It is important for future deployments, we need independent user for every backend instance. Here is how we created the users.

```sql
CREATE USER 'moderator1'@'%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON * . * TO 'moderator1'@'%';
FLUSH PRIVILEGES;

```

Next we add dump data for testing using the script below.

```sql
INSERT INTO `users` (`id`, `first_name`, `middle_name`, `surname`, `pesel`, `gender`, `birth_date`, `role`, `office_id`) VALUES

(1020, 'Ruth', 'Elion', 'Musk', 19021989, 'M', '2020-10-20', 'admin', '23'),
(1021, 'Monika', '', 'Rosa', 19021989, 'F', '1997-04-20', 'client', '24'),
(1023, 'Stanley', '', 'Murashko', 1902198, 'M', '1999-08-09', 'client', '23'),
(1024, 'Godfrey', '', 'Muga', 1902198, 'M', '1999-08-10', 'admin', '24');

INSERT INTO `cars` (`worker_id`, `plate_number`, `license_number`, `model`) VALUES
(1020, '1520', '5060', 'Toyota'),
(1021, '1521', '5061', 'Nissan'),
(1023, '1522', '5062', 'Hundai'),
(1024, '1523', '5063', 'Toyota');

INSERT INTO `offices` (`id`, `city`, `type`) VALUES
(23, 'Lodz', 'HQ'),
(24, 'Warsaw', 'BO');

```

We test Our database deployment using DBeaver desktop app:
![DBeaver](./img/db-screen2.png)


## Backend - deploy and test

To deploy backend application, we need build container from source code and run it, using commands below:
```bash
git clone https://github.com/Wredter/IAP_project_1
cd ./IAP_project_1
docker stop iap-back-container -t 1
docker rm iap-back-container
docker build --no-cache -t iap-back .
docker run -d -p 8081:80 --name=iap-back-container iap-back
```

Now we can test backend project, by send http get request on `/hello` endpoint. In Our case, we can see it on [address](http://s-vm.northeurope.cloudapp.azure.com:8081/hello)`
![back-hello](./img/back-hello.png)

On endpoint `/users` we can see list of `elements` from `users` collections
![back-users-json](./img/back-users-json.png)


## Frontend - test
For first project iteration, we need implement a few features in frontend application:
* Connection to API
* Users model
* User list view


### Connection to API
Class `FleetService` contains access to backend API using `package:http/http.dart` library
### Users 
User class is very simple, and help us to present data from Users collection from backend. We add it for test purpose, in next iteration this class will be modified, and contain expanded constructors and other methods
```dart
class User {
  int id;
  String pesel;
  String firstName;
  String sureName;

  User({this.id, this.pesel, this.firstName, this.sureName});
}
```

### User list view
Main part of view in this project is builder, which can dynamic add new elements to ListView collection
```dart
Builder(
        builder: (_) {
          if (_isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (_apiResponse.error) {
            return Center(child: Text(_apiResponse.errorMessage));
          }

          return ListView.separated(
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.green),
            itemBuilder: (_, index) {
              return Dismissible(
                key: ValueKey(_apiResponse.data[index].id),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {},
                confirmDismiss: (direction) async {
                  final result = await showDialog(
                      context: context, builder: (_) => UserDelete());
                  print(result);
                  return result;
                },
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.only(left: 16),
                  child: Align(
                    child: Icon(Icons.delete, color: Colors.white),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                child: ListTile(
                    title: Text(
                      _apiResponse.data[index].sureName,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    subtitle: Text('PESEL: ${_apiResponse.data[index].pesel}'),
                    onTap: () {}),
              );
            },
            itemCount: _apiResponse.data.length,
          );
        },
      ),
```
Application get list of users using service `fleet_service`, convert it into list of `User` objects, and present it as `ListTile` widgets:
![front-users-view](./img/front-users-view.png)

### RESOURCES for Report 1
* [REST API in flutter](https://www.youtube.com/watch?v=M8zM48Jytv0)
* [Flutter documentation](https://flutter.dev/docs)
* [Create database users](https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql)


# Report 2 - Establish the business context, sketch the system architecture, select technology
## System actors
* Headquarters Manager - Headquarters Manager represents a system role with the authorization to assign car to the branch office, update HQ car details.
* Branch Office Manager - Branch Office Manager represents a system role with the authorization to fill out the request form for the car, assign car to a worker, update BO car details.

## Activity diagram
![diagram-1](./img/diagram-1-v2.png)

## Deployment diagram
![diagram-2](./img/diagram-2-v2.svg)

## Description of use cases 
### 1. Fill out the request form (when worker needs new car)
* Type: general 
* Users: Branch Office Manager 
* Initial conditions: Branch Office Manager confirmed their identity via login and password.
* Typical step sequence:  
1. Branch Office Manager chooses an option to fill out the request form. 
2. BO Manager fills out the request form 
* Alternative sequence of steps:  
2a. Request form was filled incorrectly, BO Manager repeats filling process. 
2b. Request form was filled incorrectly, BO Manager displays help video and repeats the process. 
* Final conditions: the request form has been successfully filled. 

### 2. Assign free car (to branch) 
* Type: general
* Users: Headquarters Manager 
* Initial conditions: Headquarters Manager confirmed their identity via login and password. 
* Typical step sequence:  
1. Cache requests
2. The request validation 
3. HQ Manager assigns free car 
4. Update HQ car details 
5. Send car details to BO 
* Alternative sequence of steps: 
2a. The request is invalid (error message is sent to BO)  
3a. There is no free car (notification is sent to BO) 
* Final conditions: the free car has been assigned to BO 

### 3. Assign car to a worker 
* Type: general
* Users: Branch Office Manager 
* Initial conditions: Branch Office Manager confirmed their identity via login and password. 
* Typical step sequence:
1. Branch Office Manager assigns car to the worker. 
2. BO car details are updated. 
* Final conditions: car is assigned to worker.

## RESOURCES for report 2
* [UML deployment diagram guide](http://www.agilemodeling.com/artifacts/deploymentDiagram.htm)
* [UML activity diagram](http://www.agilemodeling.com/style/activityDiagram.htm)

* http://www.agilemodeling.com/artifacts/deploymentDiagram.htm
* http://www.agilemodeling.com/style/activityDiagram.htm



# Report 3 - Implementation of data exchange and synchronization (headquarters(HQ) / offices(BO))
![hqmodel](./deployment-diagram-28-06-2021.png)


## Application - Backend

### Data Models
As of now the data models for headquarters and branch office look pretty similar except for the responses model which takes care of all the responses the hq have ever sent to the branch office and some columns entries at branch office model are meant for data synchronization purposes.
#### HQ Model
![hqmodel](./img/hqmodel.JPG)
Below we paste a sample code for the HQ office entity as implemented in our application.
```java

@Entity
@Table(name = "offices")
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class Office {
    @Getter
    @Setter
    @Id
    @NotNull
    @Column(name = "id")
    public long id;
     
    @Getter
    @Setter
    @Column(name = "city")
    public String city;

    @Getter
    @Setter
    @Column(name = "type")
    public String type;
    
    @Getter
    @Setter
    @Column(name = "address")
    public String address;
}

```

### BO Model
![bomodel](./img/bomodel.JPG)
Below we paste a sample code for the bo users entity as implemented in our application.
```java
@Entity
@Table(name = "users")
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class User {
    @Getter
    @Setter
    @Id
    @NotNull
    @Min(40000)
    @Max(60000)
    private long id;
    

    @Getter
    @Setter
    @Column(name = "first_name")
    private String firstName;

    @Getter
    @Setter
    @Column(name = "middle_name")
    private String middleName;

    @Getter
    @Setter
    @Column(name = "surname")
    private String surname;

    @Getter
    @Setter
    @Size(min = 10, max = 12)
    @Column(name = "pesel")
    private String pesel;

    @Getter
    @Setter
    @Column(name = "gender")
    private char gender;

    @Getter
    @Setter
    @Temporal(TemporalType.DATE)
    @Column(name = "birth_date")
    private Date birthDate;


    
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "office_id", nullable = false, referencedColumnName = "id")
    private Office officeId;
    
    @Getter
    @Setter
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "role_id", nullable = false, referencedColumnName = "id")
    private Role roleId;
    
    @Getter
    @Setter
    @Column(name = "sync")
    private Boolean sync;
    

    public User(String firstName, String middleName, String surname, String pesel, char gender, Date birthDate,Role roleId,Office officeId){
        this.firstName = firstName;
        this.middleName = middleName;
        this.surname = surname;
        this.pesel = pesel;
        this.gender = gender;
        this.birthDate = birthDate;
        this.roleId = roleId;
        this.officeId = officeId;
    }
}

```
### Implementation of data exchange and synchronization
We use [RestTemplate](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/client/RestTemplate.html) class under org.springframework.web.client package to manage data exchange, and for synchronization, we use [TaskSchedular interfaces](https://docs.spring.io/spring-framework/docs/3.2.x/spring-framework-reference/html/scheduling.html) in spring boot by enabling the scheduling at the main application and use @ annotation for each method/class we need to schedule.

Enabling Scheduling in spring boot main application, @EnableScheduling and @EnableSwagger2 for documentation.
```java
package com.IAP.car_exchange;

@RestController
@SpringBootApplication
@EnableScheduling
@EnableSwagger2
public class CarExchangeApplication {

	public static void main(String[] args) {
		SpringApplication.run(CarExchangeApplication.class, args);
	}
	
	public Docket productApi() {
		return new Docket(DocumentationType.SWAGGER_2).select()
		    .apis(RequestHandlerSelectors.basePackage("com.IAP.car_exchange")).build();
		   }

	@GetMapping("/hello")
	public String hello(@RequestParam(value = "name", defaultValue = "World") String name) {
		return String.format("Hello %s!", name);
	}

}

```

#### Data exchange and synchronization for branch office
Firstly, assuming the office, role and user have been commissioned already, A user will create a request, this request will be stored in a local branch database and the RestTemplate.postForObject() method will be invoked to transfer this request to headquarter office. Incase of any failure, scheduling/synchronization has been enabled in such a way that after every 10 seconds the failed requests will be retransmitted again. Entities like User,Office, and Request have beeen synchronized such that there is a copy of each of them at the HQ server/database.

a. Synchronization properties definition
```java
package com.IAP.car_exchange;

public class SynchronizationConfiguration {
	
	// connection to HQ
	public static final String uriToHq = "http://s-vm.northeurope.cloudapp.azure.com:8081/request";
	public static final String uriToHqUser = "http://s-vm.northeurope.cloudapp.azure.com:8081/user";
	public static final String uriToHqOffice = "http://s-vm.northeurope.cloudapp.azure.com:8081/office";

	// connection from HQ
	public static final String  uriFromHq = "details";
	
	// delay sync timer in millisecond
	public static final int delay = 10000;

}

```
b. Synchronization service controller
```java
@RestController
public class SyncronizationController {
	
	
	@Autowired
	SyncronizationService syncronizationService;
	@Autowired
	SynchronizeUserService synchronizeUserService;
	@Autowired
	SynchronizeOfficeService synchronizeOfficeService;
	
	private static final Logger logger = LoggerFactory.getLogger(SyncronizationController.class);
	private static final DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("HH:mm:ss");

	
	@Scheduled(fixedDelay=SynchronizationConfiguration.delay)
	public void synchronizeRequests() {
		logger.info("Scheduled Synchronization Task for requests :: Execution Time - {}",dateFormat.format(LocalDateTime.now()));
		try {
			ResponseEntity<String> sync = syncronizationService.tryToSync();
		} catch(Exception ex) {
			logger.error("We have run into an error: we will reconnect shortly");
		}
	}
	
	@Scheduled(fixedDelay=SynchronizationConfiguration.delay)
	public @ResponseBody void synchronizeUsers() {
		logger.info("Scheduled Synchronization Task for users :: Execution Time - {}",dateFormat.format(LocalDateTime.now()));
		
		  try { ResponseEntity<String> sync = synchronizeUserService.syncUsers(); }
		  catch(Exception ex) {
		  logger.error("We have run into an error: we will reconnect shortly"); 
		  throw ex; 
		  }		
	}
	
	@Scheduled(fixedDelay=SynchronizationConfiguration.delay)
	public @ResponseBody void synchronizeOffices() {
		logger.info("Scheduled Synchronization Task for Offices :: Execution Time - {}",dateFormat.format(LocalDateTime.now()));
		
		  try { ResponseEntity<String> sync = synchronizeOfficeService.syncOffices(); }
		  catch(Exception ex) {
		  logger.error("We have run into an error: we will reconnect shortly"); 
		  throw ex; 
		  }		
	}

}

```
c. Sychronization service implementation for requests as an example.

```java
@Repository
@Data
public class SyncronizationService {
	final RequestRepository requestRepository;
	
	RequestData requestData = new RequestData();
	
	  public SyncronizationService(RequestRepository requestRepository) {
	  this.requestRepository = requestRepository; }
	 
	
	public List<Request> getAllUnsycedRequests(){
		
		return requestRepository.getAllUnyced();
	}
	
	public ResponseEntity<String> tryToSync(){
		
		
		/*
		 * List<Request> requests = syncronizationService.getAllUnsycedRequests();
		 * if(requests.isEmpty()) { System.out.println("am empty "+requests); }
		 */
		List<Request> requests = getAllUnsycedRequests();
		if (requests.isEmpty() == false) {
			for(Request r:requests) {
				//System.out.println(r.getRequestorId());
				
				// Prepare the data to be sent to HQ for this request

				requestData.setRequestorId(r.getRequestorId().getId());
				requestData.setBranchId(r.getBranchId());
				requestData.setCarModel(r.getCarModel());
				requestData.setVehiclePreffered(r.getVehiclePreffered());
				requestData.setRequestDate(r.getRequestDate());
				requestData.setRequestId(r.getRequestId());
				
				// Now send it
				//String uri = "http://localhost:8080/request";
				RestTemplate restTemplate = new RestTemplate();
				try {
				RequestData result = restTemplate.postForObject(SynchronizationConfiguration.uriToHq,requestData, RequestData.class);
				} catch(Exception e) {	
					System.out.println("We are sorry something happened we will try again later!");
					//System.out.println(requestData.getRequestorId());
					//e.printStackTrace();
					throw e;	
				}
				
				// If success, change the sync status
				r.setStatus(true);
				requestRepository.save(r);
			}
		}

		return ResponseEntity.ok(null);
	}

}

```
#### Data exchange and synchronization for head quarter office
Here, we transfer and synchnronize all the responses we have ever sent to the branch office. After we receive the car request from the branch office, we log it into the requests table and then the headquarter manager can check the pending requests, find the requested car by filtering, copy the requestid and just hit assign button and the car assignment process will proceed. Under the hood, if the car is found it's detail is packed and sent to the branch office and the necessary updates in the hq table entities is performed. If not found then the rejection notification is appended on the response. Again, the neccessary fields are updated to tell that this particular request has been processed and it is rejected.

##### Background services
a. Sychronization properties definition
```java
package com.IAP.car_exchange;

public class SynchronizationConfiguration {
	
	// connection to BO
	public static final String uriToBo = "http://s-vm.northeurope.cloudapp.azure.com:8826/details";
	
	// connection from BO
	public static final String  uriFromBo = "request";
	
	// delay sync timer in millisecond
	public static final int delay = 5000;

}

```

b. Responses synchronization controller

```java
@RestController
public class ResponsesSyncController {
	@Autowired
	ResponsesSycService responsesSycService;
	
	private static final Logger logger = LoggerFactory.getLogger(ResponsesSyncController .class);
	private static final DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("HH:mm:ss");
	
	
	@Scheduled(fixedDelay=SynchronizationConfiguration.delay)
	public void synchronizeResponses() {
		logger.info("Scheduled Synchronization Task :: Execution Time - {}",dateFormat.format(LocalDateTime.now()));
		try {
			ResponseEntity<String> sync = responsesSycService.tryToSync();
		} catch(Exception ex) {
			logger.error("We have run into an error: we will reconnect shortly");
		}
	}

}

```
c. Responses synchronization service

```java
@Repository
@Data
public class ResponsesSycService {
	
	final ResponsesRepository responsesRepository;
	
	Response response = new Response();
	
	public ResponsesSycService(ResponsesRepository responsesRepository) {
		this.responsesRepository = responsesRepository;
	}
	
	public List<Responses> getAllUnsycedResponses(){
		
		return responsesRepository.getAllUnsyc();
	}
	
	
	public ResponseEntity<String> tryToSync(){
		
		List<Responses> responses = getAllUnsycedResponses();
		if (responses.isEmpty() == false) {
			for(Responses r:responses) {
				// Prepare the data to be sent to HQ for this request
				response.setWorkerId(r.getWorkerId());
				response.setPlateNumber(r.getPlateNumber());
				response.setLicenseNumber(r.getLicenseNumber());
				response.setModel(r.getModel());
				response.setType(r.getType());
				response.setVinNumber(r.getVinNumber());
				response.setRequestId(r.getRequestId());
				response.setRequestStatus(r.getRequestStatus());
				response.setApprovedBy(r.getApprovedBy());
				response.setApprovedDate(r.getApprovedDate());
				
				// Now send it
	
				RestTemplate restTemplate = new RestTemplate();
			try {
			Response result = restTemplate.postForObject(SynchronizationConfiguration.uriToBo,response, Response.class);
			} catch(Exception e) {	
				System.out.println("We are sorry something happened we will try again later! "+e);
					throw e;	
				}
				
				// If success, change the sync status
				r.setSent(true);
				responsesRepository.save(r);
			}
		}

		return ResponseEntity.ok(null);
	}

}

```
##### Service layer descriptions
Here, we explain how we implemented the car request service. We should note that, CRUD operations have also been implemented for all the data models. Follow along the following steps:-
1. A bo user create a request -- Data access layer
   ```java
   @Data
   public class RequestData {
      Long requestId;
      Long requestorId;
      Long branchId;
      String carModel;
      String vehiclePreffered;
      Date requestDate;
      String requestStatus;
      String approvedBy;
      Date approvedDate;
      String assignedCar;
      Boolean status;
   }
 
   ```
   Data access interface - the repository
   
   ```java
   package com.IAP.car_exchange.repository;

   import java.util.List;
   import org.springframework.data.jpa.repository.JpaRepository;
   import org.springframework.data.jpa.repository.Query;

   import com.IAP.car_exchange.Model.Request;

   public interface RequestRepository extends JpaRepository<Request,Long> {
      @Query(value = "SELECT * FROM requests r ORDER BY r.request_id DESC LIMIT 1", nativeQuery = true)
      Request getLastRecord();

      @Query("SELECT r FROM Request r WHERE r.requestId=?1 AND r.assignedCar != null")
      Request getUnassignedCar(Long requestId);

      @Query("SELECT r FROM Request r WHERE r.status != true")
      List<Request> getAllUnyced();
   }
   
   ```
2. The request is stored in the database --- service layer

   A request controller
   
   ```java
   @RestController
   public class RequestController {
      @Autowired
      Querries DataAccess;

      @PostMapping("request")
      @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
       public @ResponseBody
       ResponseEntity<String> createRequest(@RequestBody RequestData dataHolder){

         // Log this Request Locally
           Request request = DataAccess.addRequest(
               dataHolder.getRequestorId(),
               dataHolder.getBranchId(),
               dataHolder.getCarModel(),
               dataHolder.getVehiclePreffered(),
               //dataHolder.getRequestDate()
               new Date()
               );       

           return ResponseEntity.ok(null);
       }

      @GetMapping("requests")
      public @ResponseBody Iterable<Request> getRequests(){
         return DataAccess.getAllRequests();
      }

       @GetMapping("request/{id}")
       public Request getRequest(@PathVariable Long id){
           return DataAccess.getRequestById(id);
       }

       @DeleteMapping("_request/{id}")
       public ResponseEntity<String> deleteRequest(@PathVariable("id") Long id){
           DataAccess.deleteRequest(id);
           return ResponseEntity.ok("Removed");
       }

   }
    
   ```
   
   A request service method for adding a request only
   
   ```java
      public Request addRequest(Long requestorId,Long branchId,String carModel,
    		String vehiclePreffered,Date requestDate) {
        User user = userRepository.findById(requestorId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid requestor Id: " + requestorId));
        Office office = officeRepository.findById(branchId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid branch Id: " + branchId));
    	Request request = Request.builder()
    			.requestorId(user)
    			.branchId(branchId)
    			.carModel(carModel)
    			.vehiclePreffered(vehiclePreffered)
    			.requestDate(requestDate)
    			.status(false)
    			.build();
    	requestRepository.save(request);
    	return request;
    }
   
   ```
   If successfully, the requests is transfered to the hq for further processes.
   
3. The hq manager will manage the requests, via the AssignCarController service
   ```java
   @RestController
   public class AssignCarController {

	@Autowired
	Querries DataAccess;
	
	@GetMapping("pendingrequests")
	public @ResponseBody Iterable<Request> getPendingRequest(){
		return DataAccess.getPendingRequests();
	}
	
	@GetMapping("filter/{model}/{type}")
	public @ResponseBody Iterable<Car> getCarByFilter(@PathVariable String model, @PathVariable String type) {
		return DataAccess.getCarByModelType(model, type);
	}
	
	@PostMapping("assign/{requestId}")
		public @ResponseBody 
		ResponseEntity<String> assign(@PathVariable Long requestId){
		Response response = DataAccess.assign(requestId);
		return ResponseEntity.ok(null);
		}
   
   ```
   At the end, the synchronization service will take of the rest, including sending back the response once the request has been attended.




## Application - Frontend

![Image](./img/frontend-gif.gif) 


Application was prepared for multiplatform usages. During tests, we use 3 deployment types:
* iOS application
* Android application
* Web application

Application was prepared for different screen sizes and proportions (landscape, horizontal, browser window)

![vImage](./img/frontend-multiplatform.png) 


Application can be used as Headquater or Branch office, and can automaticaly adapt to type of office (HQ/BO). Main color theme and operations depend on office type.

### Differnt office types 
At the beginning of application, user can select backend application, where he wants do activities. API client is prepared at the next screen (Page Login).

Moreover, at login login screen, we initialize the most important libraries.
```dart
import 'package:apiconsument/data/servers.dart';
import 'package:apiconsument/page_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/api_service.dart';

class MaterialAppHome extends StatelessWidget {
  final Server choosenServer;
  MaterialAppHome(this.choosenServer);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => ApiService.create(choosenServer.address),
      dispose: (context, ApiService service) => service.client.dispose(),
      child: MaterialApp(
        theme: ThemeData.from(
          colorScheme: choosenServer.colorScheme,
        ),
        title: choosenServer.type + ' ' + choosenServer.city,
        home: PageMenu(
          choosenServer: choosenServer,
        ),
      ),
    );
  }
}
```
Important libraries:
* Provider - library to manage communication between screens
* Chopper (here called ApiService) - library for managing API service
* Material - library with Material Design style widgets

### Dynamic build

Some views are used to build both application (for example PageListRequestsCars - but this page has a lot of differences between different office types. First - if this is HQ, list can show only pending request, and if it is HQ, user have extra button "Assign" on this page)

```dart
import 'dart:convert';
import 'data/api_service.dart';
import 'data/requestCar.dart';
import 'data/servers.dart';
import 'package:apiconsument/page_one_requestCar.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageListRequestsCars extends StatelessWidget {
  final Server choosenServer;
  final bool isPendings;

  const PageListRequestsCars({
    Key? key,
    required this.isPendings,
    required this.choosenServer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List: Requests Cars' + (isPendings ? ' Pendings' : ' ')),
      ),
      body: _buildList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  FutureBuilder<Response> _buildList(BuildContext context) {
    return FutureBuilder<Response>(
      future: isPendings
          ? Provider.of<ApiService>(context).requestsPendingsAll()
          : Provider.of<ApiService>(context).requestsAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List requestsCarsCollection =
              json.decode(snapshot.data!.bodyString);
          final List<RequestCar> requestCar = [];
          for (var item in requestsCarsCollection) {
            requestCar.add(RequestCar.fromJson(item));
          }
          if (requestCar.length == 0) {
            if (isPendings) {
              return ListView(
                children: [
                  Center(
                    child: Text(
                      "No pendings requests!",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            } else {
              return ListView(
                children: [
                  Center(
                    child: Text(
                      "No requests!",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            }
          }
          return _buildRequestCarList(context, requestCar);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  ListView _buildRequestCarList(BuildContext context, List<RequestCar> posts) {
    return ListView.builder(
      itemCount: posts.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return InkWell(
          child: posts[index].showAsCard(),
          onTap: () =>
              _navigateToRequestDetails(context, posts[index].requestId),
        );
      },
    );
  }

  _navigateToRequestDetails(BuildContext context, int requestId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PageOneRequesCar(
          choosenServer: choosenServer,
          requestId: requestId,
          isPending: isPendings,
        ),
      ),
    );
  }
}

```

### API consumption

API is consumed using Chopper library. This library can generate class for http API using simple abstract class. "To define a client, use the @ ChopperApi annotation on an abstract class that extends the ChopperService class." [More information:](https://github.com/lejard-h/chopper/blob/master/getting-started.md)
As we see, service address is declared during initialization, so we can use one API instance to prepare a lot of API services.

### Chopper API class before generate

```dart
import 'package:chopper/chopper.dart';

part 'api_service.chopper.dart';

@ChopperApi()
abstract class ApiService extends ChopperService {
  @Get(path: '/user/{id}')
  Future<Response> userById(@Path('id') int id);

  @Post(path: '/assign/{requestCarId}')
  Future<Response> assignRequestCar(@Path('requestCarId') int requestCarId);

  @Get(path: '/users')
  Future<Response> usersAll();

  @Get(path: '/office/{id}')
  Future<Response> officeById(@Path('id') int id);

  @Get(path: '/offices')
  Future<Response> officeAll();

  @Get(path: '/requests')
  Future<Response> requestsAll();

  @Post(path: '/request')
  Future<Response> postNewRequestCar(@Body() Map<String, dynamic> myRequest);

  @Get(path: '/pendingrequests')
  Future<Response> requestsPendingsAll();

  @Get(path: '/request/{id}')
  Future<Response> requestById(@Path('id') int id);

  @Get(path: '/car/{plateNumber}')
  Future<Response> carByPlateNumber(@Path('plateNumber') String plateNumber);

  @Delete(path: '/_car/{plateNumber}')
  Future<Response> deleteCarByPlateNumber(
      @Path('plateNumber') String plateNumber);

  @Delete(path: '/_user/{userId}')
  Future<Response> deleteUserById(@Path('userId') String userId);

  @Post(path: '/user')
  Future<Response> postNewUser(@Body() Map<String, dynamic> myUser);

  @Get(path: '/cars')
  Future<Response> carAll();

  @Get(path: '/posts')
  Future<Response> getPosts();

  @Get(path: '/posts/{id}')
  Future<Response> getPost(@Path('id') int id);

  @Post()
  Future<Response> postPost(
    @Body() Map<String, dynamic> body,
  );

  static ApiService create(String address) {
    final client = ChopperClient(
      baseUrl: address,
      services: [
        _$ApiService(),
      ],
      interceptors: [HttpLoggingInterceptor(), CurlInterceptor()],
      converter: JsonConverter(),
    );

    return _$ApiService(client);
  }
}
```
To generate file, in console user must type `flutter packages pub run build_runner watch` - this command observed abstract API class and generate new class with endpoints at every file saved.


### Chopper API class after generate
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$ApiService extends ApiService {
  _$ApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ApiService;

  @override
  Future<Response<dynamic>> userById(int id) {
    final $url = '/user/$id';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> assignRequestCar(int requestCarId) {
    final $url = '/assign/$requestCarId';
    final $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> usersAll() {
    final $url = '/users';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> officeById(int id) {
    final $url = '/office/$id';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> officeAll() {
    final $url = '/offices';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> requestsAll() {
    final $url = '/requests';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postNewRequestCar(Map<String, dynamic> myRequest) {
    final $url = '/request';
    final $body = myRequest;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> requestsPendingsAll() {
    final $url = '/pendingrequests';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> requestById(int id) {
    final $url = '/request/$id';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> carByPlateNumber(String plateNumber) {
    final $url = '/car/$plateNumber';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteCarByPlateNumber(String plateNumber) {
    final $url = '/_car/$plateNumber';
    final $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteUserById(String userId) {
    final $url = '/_user/$userId';
    final $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postNewUser(Map<String, dynamic> myUser) {
    final $url = '/user';
    final $body = myUser;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> carAll() {
    final $url = '/cars';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getPosts() {
    final $url = '/posts';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getPost(int id) {
    final $url = '/posts/$id';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postPost(Map<String, dynamic> body) {
    final $url = '';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}

```

### API debugging
Library can show every used request as cURL request, it can help to debug or error reproduction. It is easy to compare request from Flutter with request from Postman (both tools have option export request to cURL)
![vImage](./img/frontend-curl.png) 




### New page, new request

Requests are send when user open new page. When view is not ready, builder show Circular indicator. Application wait for respond or timeout.

```dart
import 'data/api_service.dart';
import 'data/servers.dart';
import 'data/user.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page_add_offices.dart';
import 'page_menu.dart';
import 'page_list_users.dart';

class PageAfterAddUser extends StatelessWidget {
  final User user;
  final Server choosenServer;

  const PageAfterAddUser(
      {Key? key, required this.user, required this.choosenServer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User added: ' + user.id.toString()),
      ),
      body: _buildList(context),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.backpack_outlined),
        onPressed: () => _navigateToAddOffice(context),
      ),
    );
  }

  FutureBuilder<Response> _buildList(BuildContext context) {
    return FutureBuilder<Response>(
      future: Provider.of<ApiService>(context).postNewUser(user.toJson()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final String myRespond = snapshot.data!.bodyString;
          return _buildPosts(context, myRespond);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }


Widget _buildPosts(BuildContext context, String myRespond) {
...

void _navigateToAddOffice(BuildContext context) {
...

```


### Views design - project
First project was prepared in Figma application - tool to UI design.

![Image](./img/frontend-figma.png) 

This table shows samples of views from figma and their Flutter implementations
(Violet - figma design, orange - Flutter implementation)

![view-1](./img/front-figma-create-user.png) , ![view-1](./img/front-add-user.png)
![view-2](./img/view2.png) , ![view-2](./img/front-requess-list.png)
![view-3](./img/view3.png) , ![view-3](./img/front-details.png)

### Flutter, Dart, Debug
Dart have a lot of tools (called DartDevTools) which can support develop process.

![vImage](./img/frontend-debug.png)

### RESOURCES for Report 3
1. [REST Template for Data Exchange](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/client/RestTemplate.html)
2. [Task Schedular interfaces for Data Synchronization](https://docs.spring.io/spring-framework/docs/3.2.x/spring-framework-reference/html/scheduling.html)
3. [Setting Up Swagger 2 with a Spring REST API](https://www.baeldung.com/swagger-2-documentation-for-spring-rest-api)
4. [How does Chopper work?](https://github.com/lejard-h/chopper/blob/master/getting-started.md)


# Report 4 - Performance analysis, summary and conclusions of the project
a). Introduction

In this part, we are trying to simulate the business logic (as one testsuite having seven steps as listed below) in an end to end manner where actors will be :-
1. Creating car requests, 
2. Browsing the submitted requests,
3. Browsing the unassigned requests,
4. Viewing a list of available car stock,
5. Processing/assigning the cars requested,
6. Adding cars to the stock, as new cars have just arrived to our warehouse, and
7. Filtering the requested car by model and car type.

The figure below shows the testsuite setup in soapUI
![test-suite](./img/test-suite.PNG)

* Performance testing tool

    We use SoapUI `5.6.0` (open-source) to perform set and run the performance test for our REST API. The open-source version of SoapUI can handle a limited number of concurrent       threads (i.e [200](https://www.soapui.org/docs/load-testing/threads/)) at its basic configuration, therefore we altered these basic configurations inorder to support up to       2000 threads. However, increasing the number of threads triggers another key problem, the memory limitations which leads to not able to run a load test continuously over a 	long period of time. Yet, there is a workaround for improving memory usage as described  [here](https://www.soapui.org/docs/load-testing/memory-management/) and [here](https://www.soapui.org/getting-started/working-with-soapui/improving-memory-usage/). Improving memory usage by changing the basic settings is limited on the hardware 	          capabability of the testing machine, for our case the testing computer had a 8GHz RAM and Core i5-4258U CPU @2.4GHz 2.4GHz. Due to those limitations, the simulation was 	   performed for approximately 60 minutes.
    
* Testing strategies
    * The Thread strategy - We linearly change the number of threads/virtual users from one level to another over the run of load test. We aim at establishing the threads 	       baseline above 	which the application will start flooding with errors. We then, determine the average data volume which our application can handle just before errors 	         occur, and finally establish the average response time.

b). Performance analysis

The test was set and run as described in part (a), and logs were collected for analysis. The figure below shows the trend between threads and errors. It can be observed that after **836** threads, the total error just started to increase. The gray line depicts the bound above which the total errors are above zero.
![threads](./img/threads.PNG)

* We also observed on how much volume of data can be processed over the test period.It can be stated that as the number of threads were increasing so do the data volume (bytes) which were being sent to the server. Just before the errors a total volume of **360 GB** were transacted at a rate of 72 mbps. The plot below shows the data volume (bytes), response time (avg in millisecond), speed (bps), and threads over the test duration. Note that, the vertical scale is logarithmic.

![volume](./img/volume.PNG)

* The average response time in millisecond (avg) were gradually increasing as the number of threads were increasing. Just before the errors, the average response time was around **9.6 seconds**.


c). Summary

Below table depicts the overall statistical summary of the performance testing over the test duration. It can be seen that, our application had a total of 21 errors, about 400 GB data volume were transacted.

![test-summary](./img/test_summary.PNG)

d). Conclusion

This marks the end of the project, but before the dead end each team member would like to highlight some thoughts on the challenges, skills gained, etc during the course of project realization.

* First, I would like to thank God for keeping me safe during the semester. Second, I extend my heartfelt gratitude to our lecturer Mr. Wiktor Wandachowicz for his tireless 	guidance and support during the project realization. Technically, It was my first time to realize a project in an end-to-end manner from the designing and testing stage. The following were the technical skills gained during the semester for this course. First, developing a web API using the JAVA spring boot framework. It was a headache at first since I did not program with java before, but thanks to team members for their support and thoughts on some resource links. Second, the understanding of the basic architecture of the REST API, some new keywords like endpoints, resources, different layers from data access up to presentation layer, and how to differentiate them. Third, working with JPA and SQL interchangeably. Fourth, realizing synchronization between two APIs and observing that the setup works as it is supposed to work was a joyous moment. Fifthly, it was my first time working with performance testing tools like SoapUI, and I know some ins and outs of this tool, at least the open-source one, from setting up and running the test using various strategies, environment properties expansion, adjusting memory settings in a bin folder in case you want to test the heavy load, and many more. Sixth, docker basic commands knowledge, for example, commands for building and running container images. I also gained knowledge on online tools for fast-creating database table models. Working with the support team was also a great advantage of this project as we always helped each other. THANKS, TEAM 💯 -- ~**GODFREY MGHASE**
* Participation in the project gave me an opportunity to amplify my interests and was an outstanding chance to expand my knowledge of developing web applications. Among the skills and knowledge acquired during the project is the understanding of the architecture of REST API. My knowledge about software engineering and User Interface designing was significantly extended. During project realisation I had used Figma application in order to design views, which was a new experience for me. Due to Figma’s useful prototyping features, I plan to use this tool in the future as well. Furthermore, I expanded my knowledge of software engineering such as creating diagrams (deployment diagram, activity diagram) with usage of online tools and describing use cases. Moreover, I have improved my organisational, interpersonal and managerial skills. Working in the team, was a beneficial experience and allowed us to exchange our knowledge. All team members were supportive, reliable and engaged in the work, therefore it has been a pleasure working with all of you. – ~**MONIKA ROSA**
* First of all, Thank to Mr. Wiktor Wandachowicz for his lectures and laboratory meetings - this lessons help us solve some problems with project. Second, thank to IAP group8 team for cooperation and development process. Thanks to this project, I develop my soft and hard skills. Below I write some insights:
  1. Swagger is amazing tool, and this is more than "swagger-ui.html" what I know before project. Swagger hub can help manage Our API for different applications and different version of API. Using Swagger we can design API in YAML BEFORE development stage. Swagger can generate not only client code, moreover can generate server side code.
  2. Befor project I have some CI/CD projects with Azure DevOps, Jenkins and other tools, but now I know that it is very easy to set trigger on ACR and deploy image from ACR stright to WebApp Container, it is simple and powerfull tool, amazing for test a lot of instances, and not necessary duplicate whole pipelines, it just webhook. Every `docker push` is new deployment, without any advanced CI/CD tools.
  3. Figma is amazing tool for prototyping. Here is a lot of plugins to generate code (I try `FigmaToFlutter` and `Figma to Code` plugins). But plugins not every time working correct, so at this project we prepare views manually based on Figma project, not generate them automatically. In the future projects we must take care about it, select the best plugin and generate views directly from Figma.
  4. Flutter 2.x is now `null-safety`, thank to this code is better, but development process last longer that I expected after working with Flutter 1.x.
  5. When frontend application do not need acces to hardware (Camera, Bluetooth, Local Storage, etc.), it is very simple to develop multiplatform code. Our project was tested on `Android`, `iOS`, and `Web`. One code for a lot of platforms, and only one, little problem - for Web project we need only add CORS on server side. So Flutter is for me the best framework for rapid development application for API consumption.
  6. Chopper is very interesting library and easy to use.
  7. First time we test web application during load test, and we know that Our server can working with about `800` users at the same time per Office instance. It is great score, because we acheve it on ASP server 3.5GB RAM 2vCPU where we had a lot of other applications hosted on same ASP!
  8. It was amazing challenge and interesting course, thank You one more time, ~**STANISŁAW PUŁAWSKI**
* Spring boot is nice framework for API development and backend applications as it has made easier to fast create a web application. Using swagger-ui.html endpoint we can rapid test backend service inside browser - we do not need postman, curl or SoapUI for it. Taking part in this project was a great opportunity for me to expand not only technical abilities but also my multi-tasking skills, managerial as well as organizational skills. ~**WIKTOR MURASZKO**


e) RESOURCES for report 4
1. [Concurrent threads limitation in SoapUI](https://www.soapui.org/docs/load-testing/threads/)
2. [Memory management in SoapUI part 1 ](https://www.soapui.org/docs/load-testing/memory-management/)
3. [Memory management in SoapUI part 2 ](https://www.soapui.org/getting-started/working-with-soapui/improving-memory-usage/)
4. [Simulating different types of load](https://www.soapui.org/docs/load-testing/simulating-different-types-of-load/)
5. [Azure Container Register webhooks](https://docs.microsoft.com/en-us/cli/azure/acr/webhook?view=azure-cli-latest)
6. [Swagger editor online](https://editor.swagger.io/)
7. [FigmaToFlutter plugin](https://www.figma.com/community/plugin/844008530039534144/FigmaToFlutter)
