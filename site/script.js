const skills = [
  "AWS","Terraform","IaC","Docker","Kubernetes","Helm","GitHub Actions",
  "CI/CD","Linux","Python","Bash","EC2","EKS","ECS","RDS","VPC",
  "ALB/NLB","Route 53","CloudFront","S3","CloudWatch","Lambda","API Gateway",
  "IAM","SSM","WAF","Cost Optimization"
];

const wrap = document.getElementById("skills");
skills.forEach(s => {
  const el = document.createElement("span");
  el.className = "chip";
  el.textContent = s;
  wrap.appendChild(el);
});

document.getElementById("year").textContent = new Date().getFullYear();

const canvas = document.getElementById("stars");
const ctx = canvas.getContext("2d");

function resize() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}
window.addEventListener("resize", resize);
resize();

const STAR_LAYERS = 3;
const STARS_PER_LAYER = 220;
const stars = [];

function initStars() {
  stars.length = 0;
  for (let layer = 1; layer <= STAR_LAYERS; layer++) {
    for (let i = 0; i < STARS_PER_LAYER; i++) {
      stars.push({
        layer,
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * (0.8 + layer * 0.7) + 0.2,
        alpha: Math.random() * 0.7 + 0.2,
        speed: 0.03 * layer
      });
    }
  }
}

initStars();

function animate() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  stars.forEach(s => {
    ctx.globalAlpha = s.alpha;
    ctx.fillStyle = "#ffffff";
    ctx.beginPath();
    ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
    ctx.fill();

    s.alpha += (Math.random() - 0.5) * 0.02;
    s.alpha = Math.max(0.15, Math.min(1, s.alpha));

    s.x -= s.speed;
    if (s.x < 0) {
      s.x = canvas.width;
      s.y = Math.random() * canvas.height;
    }
  });

  requestAnimationFrame(animate);
}

animate();