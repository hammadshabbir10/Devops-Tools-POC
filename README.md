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

# DEVOPS PROJECT

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


![Image](https://github.com/user-attachments/assets/973ff320-ab69-495d-b0ab-0c207854d5fe)



docker ps -a

![Image](https://github.com/user-attachments/assets/30b7b7b2-5b9b-468c-b541-8ff5f157f4b6)


docker images

![Image](https://github.com/user-attachments/assets/9e7e41fd-cce1-4f5f-9dc0-b05339cbf575)


# 3- Kubernetes

- kubectl create namespace movie-booking
- kubectl apply -f k8s_specifications/
- kubectl get namespace

my- namespace is kube-system & movie-booking

![Image](https://github.com/user-attachments/assets/8b312f61-3941-42e0-a8ae-71787e95550e)


![Image](https://github.com/user-attachments/assets/41678a5e-5f01-43de-962f-e5bd183aeb36)


kubectl get pods -n movie-booking

![Image](https://github.com/user-attachments/assets/3c069472-802b-4b58-b1f3-3d93be0b1793)



kubectl get pv,pvc -n movie-booking
kubeclt get svc -n movie-booking

![Image](https://github.com/user-attachments/assets/d9fae7c9-0b21-40fe-adbe-8925a64908d2)


kubeclt get ingress -n movie-booking

![Image](https://github.com/user-attachments/assets/2eaaf07b-d623-4e93-9bb5-1832633beeb1)


kubectl get deployments -n movie-booking

![Image](https://github.com/user-attachments/assets/d17aa035-6f22-4dd6-b897-945ec4bac712)


kubectl get scerts -n movie booking

![Image](https://github.com/user-attachments/assets/2efb37aa-3601-4e63-806c-795104d41ef0)


k8s_Specification (kubernestes folders)


![Image](https://github.com/user-attachments/assets/8c329d11-253d-4421-a46b-3cbeda0fe8f7)


## BACKEND-ENTERIES IN KUBERNETES THROUGH POSTMAN

kubectl port-forward svc/mysql 3307:3306 -n movie-booking
kubectl exec -it mysql-bc774658b-qkdsp -n movie-booking -- mysql -uroot -pmypassword

# For USERS

url: http://localhost:30000/users

![image](https://github.com/user-attachments/assets/be0c4b7a-82f6-429e-b736-e2c7c3fd702e)


kubectl port-forward svc/user-service 5000:5000 -n movie-booking

![Image](https://github.com/user-attachments/assets/a6dc0714-2e76-43a5-a475-1139689fcac3)


New user has been entered.


# FOR MOVIES

url: http://localhost:30001/movies

![Image](https://github.com/user-attachments/assets/4978640c-40e3-4794-a907-e8eff1ba7014)


kubectl port-forward svc/movie-service 5001:5001 -n movie-booking

![Image](https://github.com/user-attachments/assets/831ca2c1-6851-479c-a535-db0935114842)


# For Showtime

url: http://localhost:30001/showtimes

![Image](https://github.com/user-attachments/assets/d2e7d677-1951-45fd-9fb0-50fe2c161e2c)


kubectl port-forward svc/showtime-service 5002:5002 -n movie-booking

![Image](https://github.com/user-attachments/assets/e47e4035-803c-4a1d-b180-a4247451a4b1)


# For Bookings;

url: http://localhost:30003/bookings

![Image](https://github.com/user-attachments/assets/e5682200-6caa-4af1-be44-d1c86d1d0f79)


kubectl port-forward svc/booking-service 5003:5003 -n movie-booking

![Image](https://github.com/user-attachments/assets/40b1b258-bef5-48a2-a2e7-290d783cc7d1)


# 4- ARGO-CD


![Image](https://github.com/user-attachments/assets/1485f3df-59cd-46ee-82dc-0af175ca8f45)

kubectl apply -f argocd/movie-booking-app.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443

![Image](https://github.com/user-attachments/assets/9c715ea3-799c-4c9d-8f5e-ea501156f8bb)


kubectl get pods -n argocd
https://localhost:8080


![Image](https://github.com/user-attachments/assets/b5c14a17-00bd-4b44-9bc7-7432c76ce528)


![Image](https://github.com/user-attachments/assets/20ce12b7-1532-4dbd-9263-cdc56420828b)



# 5- CI-CD PIPLINE

![Image](https://github.com/user-attachments/assets/2b9f9aab-f353-4658-ae1f-593d60bb105d)


# F-Terraform
•	Terraform init
•	Terraform plan


![Image](https://github.com/user-attachments/assets/6eb4802c-6083-415e-afab-181f7e290b9e)


![Image](https://github.com/user-attachments/assets/2f4cc608-c3b1-426e-9a22-87d328d57d70)


![Image](https://github.com/user-attachments/assets/980c6127-efcc-4b13-9753-3882b3f081f4)



# MY KEYS

![Image](https://github.com/user-attachments/assets/3dd296a7-2530-41c7-b4f9-e0d85bde1203)

# 6- ANSIBLE

-	pip install kubernetes
-	pip install ansible
-	pip install openshift
-	ansible-galaxy collection install kubernetes.core
-	ansible-galaxy collection install community.general



