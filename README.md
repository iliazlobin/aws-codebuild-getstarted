Before applying Terraform code change dockerhub credentials in the file *terraform-dockerhub/secretmanager.tf*

Zip codebuild input:
```bash
cd codebuild-input
zip -r codebuild-input.zip ./*
mv codebuild-input.zip ../
cd ../
```

Upload to the bucket
```bash
aws s3 create-bucket --bucket codebuild-690612908881-input
aws s3 create-bucket --bucket codebuild-690612908881-output
aws s3 cp ./codebuild-input.zip s3://codebuild-690612908881-input/
```

code build role:
```bash
aws iam create-role --role-name CodeBuildServiceRole --assume-role-policy-document file://codebuild-role.json
aws iam put-role-policy --role-name CodeBuildServiceRole --policy-name CodeBuildServiceRolePolicy --policy-document file://codebuild_policy.json
```

Code build CLI:
```bash
aws codebuild create-project --cli-input-json file://codebuild_project.json
aws codebuild start-build --project-name codebuild_project
```

```bash
aws codebuild create-project --cli-input-json file://codebuild_project_dockerhub.json
aws codebuild start-build --project-name codebuild_project_dockerhub
```

```bash
aws codebuild update-project --name codebuild_project --cli-input-json file://codebuild_project.json
aws codebuild start-build --project-name codebuild_project
```

Recreate project & start build
```bash
aws codebuild delete-project --name codebuild_project
aws codebuild create-project --cli-input-json file://codebuild_project.json
aws codebuild start-build --project-name codebuild_project
```

```bash
mkdir -p output/
aws s3 cp s3://codebuild-690612908881-output/codebuild_project/target/messageUtil-1.0.jar ./output/
cd output/
jar -xf messageUtil-1.0.jar
cd ../
```

# Clear up
```bash
aws secretsmanager delete-secret --secret-id dockerhub-credentials-iliazlobin --force-delete-without-recovery
```

# Custom runtime
```bash
docker pull adoptopenjdk/openjdk11:latest
docker tag $(docker images adoptopenjdk/openjdk11:latest --format {{.ID}}) iliazlobin/openjdk11:latest
docker push iliazlobin/openjdk11
```

```bash
docker pull maven:3-jdk-11-slim
docker tag $(docker images maven:3-jdk-11-slim --format {{.ID}}) iliazlobin/maven:3-jdk-11-slim
docker push iliazlobin/maven:3-jdk-11-slim
```

* [builde spec reference](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)
* [project environment specification](https://docs.aws.amazon.com/codebuild/latest/APIReference/API_ProjectEnvironment.html)
* [create a secret for private registry](https://docs.aws.amazon.com/codebuild/latest/userguide/sample-private-registry.html)
