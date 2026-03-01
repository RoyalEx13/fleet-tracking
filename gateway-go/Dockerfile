# ใช้ Stage เดียวเพื่อให้มี Go Compiler สำหรับ Rebuild ตลอดเวลา
FROM golang:1.25-alpine

WORKDIR /app

RUN go install github.com/air-verse/air@latest

COPY go.mod ./
RUN go mod download

COPY . .

EXPOSE 8080

CMD ["air", "-c", ".air.toml"]