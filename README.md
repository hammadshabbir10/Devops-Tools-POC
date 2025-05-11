# Cinema 3 - Example of Microservices in Python


# Overview

Cinema 3 is an example project which demonstrates the use of microservices for a fictional movie theater. 
The Cinema 3 backend is powered by 4 microservices, all of which happen to be written in Python using FLASK

 - Movie Service: Provides information like movie ratings, title, etc.
 - Show Times Service: Provides show times information.
 - Booking Service: Provides booking information. 
 - Users Service: Provides movie suggestions for users by communicating with other services.


# Requirements

- Python 2.7
- Works on Linux, Windows, Mac OSX and (quite possibly) BSD.


# Devops-Tools-POC

A project demonstrating end-to-end DevOps practices—containerization (Docker), orchestration (Kubernetes), IaC (Terraform), configuration management (Ansible), CI/CD (GitHub Actions), and GitOps (ArgoCD)—applied to a [movie-booking/e-commerce/etc.] application. Focuses on automation, scalability, and deployment best practices.


# Group Members:

- Hammad Shabbir, 22I-1140
- Iqrash Qureshi, 22I-1174
- Haider Zia, 22I-1196

#### DEVOPS PROJECT

## Apply Devops Tools:

-	Github Repo
-	Docker
-	Kubernetes
-	CI-CD Pipeline
- ARGO CD
- Terraform
- Ansible


# 1- Gitub Repo

![image](https://github.com/user-attachments/assets/b9526ef7-7d99-48df-b107-831f3fc5206c)


# 2- Docker


![image](https://github.com/user-attachments/assets/6f9a6a5f-7472-48ed-a0af-2a035e3870d3)


docker ps -a

![image](https://github.com/user-attachments/assets/1b7a4442-17b5-46bd-afbe-98381af923d6)


docker images

![image](https://github.com/user-attachments/assets/40dbc94d-10a8-4e23-a1b6-1d5f497a5876)


# 3- Kubernetes

- kubectl create namespace movie-booking
- kubectl apply -f k8s_specifications/
- kubectl get namespace

my- namespace is kube-system & movie-booking

![image](https://github.com/user-attachments/assets/2161e4dc-360d-4426-ac36-77e53b372c57)


![image](https://github.com/user-attachments/assets/3539f3ea-9862-4291-ac53-2d45cc53ba1f)


kubectl get pods -n movie-booking



kubectl get pv,pvc -n movie-booking
kubeclt get svc -n movie-booking

![image](https://github.com/user-attachments/assets/1963acb1-cec0-4b18-9022-f8891edb9061)


kubeclt get ingress -n movie-booking

![image](https://github.com/user-attachments/assets/1e0d726f-938c-499d-962f-784c5ca856d2)


kubectl get deployments -n movie-booking

![image](https://github.com/user-attachments/assets/82e7c911-6db7-4bb5-bc8d-a17d3d8e11de)


kubectl get scerts -n movie booking

![image](https://github.com/user-attachments/assets/0fcc7b42-4801-48d4-87f9-e46b2565b157)


k8s_Specification (kubernestes folders)


![image](https://github.com/user-attachments/assets/50a0a6c9-152d-4eea-b4ea-f83fced8a1f2)


## BACKEND-ENTERIES IN KUBERNETES THROUGH POSTMAN

kubectl port-forward svc/mysql 3307:3306 -n movie-booking
kubectl exec -it mysql-bc774658b-qkdsp -n movie-booking -- mysql -uroot -pmypassword

# For USERS

url: http://localhost:30000/users

![image](https://github.com/user-attachments/assets/be0c4b7a-82f6-429e-b736-e2c7c3fd702e)


kubectl port-forward svc/user-service 5000:5000 -n movie-booking

![image](https://github.com/user-attachments/assets/fb6bc19e-ddfa-452f-b3fa-599d299d5b63)

New user has been entered.


# FOR MOVIES

url: http://localhost:30001/movies

![image](https://github.com/user-attachments/assets/e4b81867-8666-4adb-8be6-0959343cf0a7)


kubectl port-forward svc/movie-service 5001:5001 -n movie-booking

![image](https://github.com/user-attachments/assets/680886ee-ce0a-44b1-8277-6050d6d82f55)


# For Showtime

url: http://localhost:30001/showtimes

![image](https://github.com/user-attachments/assets/ea473ce6-b7eb-437d-85f2-d324e34c30ed)


kubectl port-forward svc/showtime-service 5002:5002 -n movie-booking

![image](https://github.com/user-attachments/assets/d86c0581-9f8c-483f-9f52-0691c9c0dab2)


# For Bookings;

url: http://localhost:30003/bookings

![image](https://github.com/user-attachments/assets/298ca600-f369-409d-9eff-8a087a88c1d4)


kubectl port-forward svc/booking-service 5003:5003 -n movie-booking

![image](https://github.com/user-attachments/assets/40d8e54e-ddf9-4bb2-ae23-804cc35ef923)


# 4- ARGO-CD


![image](https://github.com/user-attachments/assets/a9e7a952-4763-4511-a1f6-27dec3760dd8)

kubectl apply -f argocd/movie-booking-app.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443

![image](https://github.com/user-attachments/assets/433b8240-7a53-4109-a3b6-90959d6ebd53)


kubectl get pods -n argocd
https://localhost:8080


![image](https://github.com/user-attachments/assets/d6c3a4c7-b087-4a2b-a892-876e2c64102d)


![image](https://github.com/user-attachments/assets/c8049f76-1f08-4b9f-88d4-009c03921705)



# 5- CI-CD PIPLINE

![image](https://github.com/user-attachments/assets/2ddd83ae-d157-4e22-9950-98c2832be487)


# F-Terraform
•	Terraform init
•	Terraform plan


![image](https://github.com/user-attachments/assets/fa6acb0e-6f78-4c93-9923-b8add47833d0)


![image](https://github.com/user-attachments/assets/df8ddad0-46e2-42ea-9e87-57089c18f3e6)


![image](https://github.com/user-attachments/assets/b8e8d789-2f07-4ca8-a894-e58bb266db04)



# MY KEYS

![image](https://github.com/user-attachments/assets/000de0eb-6dcc-4cd8-b864-f314f0b922b4)


# 6- ANSIBLE

-	pip install kubernetes
-	pip install ansible
-	pip install openshift
-	ansible-galaxy collection install kubernetes.core
-	ansible-galaxy collection install community.general



