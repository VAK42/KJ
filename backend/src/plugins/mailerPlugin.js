import nodemailer from 'nodemailer';
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: 'vak@example.com',
    pass: '14125',
  },
});
async function sendCode(to, subject, code) {
  await transporter.sendMail({
    from: 'KJ',
    to,
    subject,
    html: `<p>Your KJ Verification Code Is: <strong style="font-size:24px;letter-spacing:4px">\${code}</strong></p><p>Expires In 10 Minutes!</p>`,
  });
}
export default { sendCode };