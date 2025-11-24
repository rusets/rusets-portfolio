const skills = [
  "AWS", "Terraform", "IaC", "Docker", "Kubernetes", "Helm", "GitHub Actions",
  "CI/CD", "Linux", "Python", "Bash", "EC2", "EKS", "ECS", "RDS", "VPC",
  "ALB/NLB", "Route 53", "CloudFront", "S3", "CloudWatch", "Lambda",
  "API Gateway", "IAM", "SSM", "WAF", "Cost Optimization"
];

const skillsWrap = document.getElementById("skills");
if (skillsWrap) {
  skills.forEach((s) => {
    const el = document.createElement("span");
    el.className = "chip";
    el.textContent = s;
    skillsWrap.appendChild(el);
  });
}

const yearSpan = document.getElementById("year");
if (yearSpan) {
  yearSpan.textContent = new Date().getFullYear();
}

const canvas = document.getElementById("stars");
if (canvas && canvas.getContext) {
  const ctx = canvas.getContext("2d");

  function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }

  window.addEventListener("resize", resize);
  resize();

  const stars = Array.from({ length: 260 }, () => ({
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    r: Math.random() * 1.6 + 0.3,
    o: Math.random() * 0.6 + 0.25
  }));

  function animate() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    stars.forEach((s) => {
      ctx.globalAlpha = s.o;
      ctx.fillStyle = "#fff";
      ctx.beginPath();
      ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
      ctx.fill();

      s.o += (Math.random() - 0.5) * 0.03;
      s.o = Math.max(0.12, Math.min(0.8, s.o));
    });

    requestAnimationFrame(animate);
  }

  animate();
}