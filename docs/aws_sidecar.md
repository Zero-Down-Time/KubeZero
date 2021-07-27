```
      - args:
        - -c
        - sleep 3600
        command:
        - /bin/sh
        env:
        - name: AWS_ROLE_ARN
          value: <ARN>
        - name: AWS_WEB_IDENTITY_TOKEN_FILE
          value: /var/run/secrets/sts.amazonaws.com/serviceaccount/token
        image: amazon/aws-cli
        imagePullPolicy: Always
        name: busybox
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/sts.amazonaws.com/serviceaccount/
          name: aws-token
          readOnly: true
```
