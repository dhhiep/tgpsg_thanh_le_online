# TGPSG Thánh Lễ Trực Tuyến Fetcher  

This project is an API wrapper for the YouTube channel **[TGPSG Thánh Lễ Trực Tuyến](https://www.youtube.com/channel/UCc7qu2cB-CzTt8CpWqLba-g)**, providing the following APIs:  

| Method | Endpoint                                      | Description                                                                                      |
| ------ | --------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| GET    | `/api/masses`                                 | Retrieves a list of masses from the past month, including upcoming, live, and streamed (with response caching). |
| GET    | `/api/masses?reload_cache=true`              | Retrieves a list of masses from the past month, including upcoming, live, and streamed (without response caching). |
| GET    | `/api/masses?action=video&video_id=JeCseNyJD9c` | Fetches video data by video ID.                                                                  |

---

## I. Setup

### 1. Copy `.env.template` to `.env` and update your keys.
### 2. Follow these steps to get started:

```bash
$ ./bin/bootstrap
$ ./bin/setup
$ ./bin/test
```

To deploy your Lambda function, follow these steps. This command assumes you have the AWS CLI configured with credentials located in your `~/.aws` directory.

```shell
$ STAGE_ENV=live ./bin/deploy
```

To test its functionality within the AWS Console, you can either:
- Send a test event:  
  **Services -> Lambda -> MYLAMBDA -> Test**
- If you opted for a basic HTTP API, check your Invoke URL by navigating to:  
  **Services -> API Gateway -> MYAPI -> Invoke URL**

---

## II. CI/CD with GitHub Actions

For GitHub to deploy your Lambda function, it needs permission to do so. An admin should perform the first deployment. Afterward, GitHub Actions can handle updates automatically.

### 1. Create a Deploy User

In the AWS Console:  
**IAM -> Users -> Add User**

- Check the **"Programmatic access"** option.
- Select **"Attach existing policies directly"**.
- Select the **"AWSLambdaFullAccess"** policy.
- Copy the **Access Key ID** and **Secret Access Key**.

### 2. AWS Credentials

In your GitHub repository:

- Go to **Settings -> Secrets -> Add a new secret**.
- Add the following secrets:
  - **Name:** `AWS_ACCESS_KEY_ID`  
    **Value:** *(Paste the Access Key ID from the previous step)*
  - **Name:** `AWS_SECRET_ACCESS_KEY`  
    **Value:** *(Paste the Secret Access Key from the previous step)*
