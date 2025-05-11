
# Cinema 3 - Example of Microservices in Python


Overview
========

Cinema 3 is an example project which demonstrates the use of microservices for a fictional movie theater. 
The Cinema 3 backend is powered by 4 microservices, all of which happen to be written in Python using 
Flask. For more information, you can refer to the blog post here: https://codeahoy.com/2016/07/10/writing-microservices-in-python-using-flask/

 * Movie Service: Provides information like movie ratings, title, etc.
 * Show Times Service: Provides show times information.
 * Booking Service: Provides booking information. 
 * Users Service: Provides movie suggestions for users by communicating with other services.

Requirements
===========

* Python 2.7
* Works on Linux, Windows, Mac OSX and (quite possibly) BSD.

=======
# Devops-Tools-POC
A project demonstrating end-to-end DevOps practices—containerization (Docker), orchestration (Kubernetes), IaC (Terraform), configuration management (Ansible), CI/CD (GitHub Actions), and GitOps (ArgoCD)—applied to a [movie-booking/e-commerce/etc.] application. Focuses on automation, scalability, and deployment best practices.


# Group Members:

Hammad Shabbir, 22I-1140
Iqrash Qureshi, 22I-1174
Haider Zia, 22I-1196

# DEVOPS PROJECT

## Apply Devops Tools:

•	Github Repo
•	Docker
•	Kubernetes
•	CI-CD Pipeline
•	ARGO CD
•	Terraform
•	Ansible

# A-Gitub Repo

# B-Docker

docker ps -a

docker images


# C-Kubernetes

kubectl create namespace movie-booking
kubectl apply -f k8s_specifications/

kubectl get namespace
my- namespace is kube-system & movie-booking

kubectl get pods -n movie-booking


kubectl get pv,pvc -n movie-booking
kubeclt get svc -n movie-booking

kubeclt get ingress -n movie-booking

kubectl get deployments -n movie-booking

kubectl get scerts -n movie booking


k8s_Specification (kubernestes folders)


## BACKEND-ENTERIES IN KUBERNETES THROUGH POSTMAN

kubectl port-forward svc/mysql 3307:3306 -n movie-booking
kubectl exec -it mysql-bc774658b-qkdsp -n movie-booking -- mysql -uroot -pmypassword

# For USERS

url: http://localhost:30000/users


kubectl port-forward svc/user-service 5000:5000 -n movie-booking
New user has been entered.


# FOR MOVIES

url: http://localhost:30001/movies


kubectl port-forward svc/movie-service 5001:5001 -n movie-booking


# For Showtime

url: http://localhost:30001/showtimes


kubectl port-forward svc/showtime-service 5002:5002 -n movie-booking


# For Bookings;

url: http://localhost:30003/bookings


kubectl port-forward svc/booking-service 5003:5003 -n movie-booking



# D-ARGO-CD


kubectl apply -f argocd/movie-booking-app.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443

kubectl get pods -n argocd
https://localhost:8080


# E-CI-CD PIPLINE



# F-Terraform
•	Terraform init
•	Terraform plan


MY KEYS



# G-	ANSIBLE

•	pip install kubernetes
•	pip install ansible
•	pip install openshift
•	ansible-galaxy collection install kubernetes.core
•	ansible-galaxy collection install community.general



