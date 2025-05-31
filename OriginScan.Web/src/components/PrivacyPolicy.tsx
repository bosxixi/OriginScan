import React from 'react';
import { Link } from 'react-router-dom';
import '../styles/PrivacyPolicy.css';

const PrivacyPolicy: React.FC = () => {
  return (
    <div className="privacy-content">
      <h1>Privacy Policy for OriginScan</h1>
      <p>Effective date: August 10, 2022</p>

      <p>SCORPIOX, INC LIMITED ("us", "we", or "our") built the OriginScan app as a Commercial app. This SERVICE is provided by SCORPIOX, INC LIMITED and is intended for use as is.</p>

      <p>At OriginScan.scorpioplayer.com, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by OriginScan.scorpioplayer.com and how we use it.</p>

      <p>If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us through email at support@scorpioplayer.com.</p>

      <h2>Information Collection and Use</h2>
      <p>For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to your email address, name, and other information ("Personal Information"). The information that we request will be retained by us and used as described in this privacy policy.</p>

      <p>The app does use third-party services that may collect information used to identify you. Below is a list of third-party service providers used by the app:</p>
      <ul>
        <li>Azure API Services</li>
        <li>Visual Studio App Center Analytics</li>
        <li>Visual Studio App Center Crashlytics</li>
        <li>Application Insights</li>
        <li>Google User Data</li>
      </ul>

      <h2>OriginScan app accesses and uses Google user data as follows:</h2>
      <ul>
        <li><strong>Accessed Data:</strong> We may access your Google account email, profile information, and other data as authorized by you.</li>
        <li><strong>Usage:</strong> The data is used to enhance your experience on OriginScan app by personalizing content, managing subscriptions, and providing seamless integration with Google services.</li>
        <li><strong>Sharing and Disclosure:</strong> We do not share, transfer, or disclose your Google user data with any third parties except as required by law or with your explicit consent.</li>
        <li><strong>Data Protection Mechanisms:</strong> We implement industry-standard security measures to protect your Google user data, including encryption and secure storage.</li>
        <li><strong>Retention and Deletion:</strong> Google user data is retained only as long as necessary to provide our services or as required by law. You may request deletion of your data by contacting us at support@scorpioplayer.com.</li>
      </ul>

      <h2>Log Files</h2>
      <p>OriginScan.scorpioplayer.com follows a standard procedure of using log files. These files log visitors when they visit websites. All hosting companies do this as a part of hosting services' analytics. The information collected by log files includes internet protocol (IP) addresses, browser type, Internet Service Provider (ISP), date and time stamp, referring/exit pages, and possibly the number of clicks. These are not linked to any information that is personally identifiable. The purpose of the information is for analyzing trends, administering the site, tracking users' movement on the website, and gathering demographic information.</p>

      <h2>Cookies</h2>
      <p>Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.</p>

      <p>This Service does not use these "cookies" explicitly. However, the app may use third-party code and libraries that use "cookies" to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.</p>

      <h2>Third Party Privacy Policies</h2>
      <p>OriginScan.scorpioplayer.com's Privacy Policy does not apply to other advertisers or websites. Thus, we are advising you to consult the respective Privacy Policies of these third-party ad servers for more detailed information. It may include their practices and instructions about how to opt-out of certain options. You can choose to disable cookies through your individual browser options. To know more detailed information about cookie management with specific web browsers, it can be found at the browsers' respective websites.</p>

      <h2>Children's Information</h2>
      <p>Another part of our priority is adding protection for children while using the internet. We encourage parents and guardians to observe, participate in, and/or monitor and guide their online activity.</p>

      <p>OriginScan.scorpioplayer.com does not knowingly collect any Personal Identifiable Information from children under the age of 13. If you think that your child provided this kind of information on our website, we strongly encourage you to contact us immediately and we will do our best efforts to promptly remove such information from our records.</p>

      <h2>Online Privacy Policy Only</h2>
      <p>This privacy policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect on OriginScan.scorpioplayer.com. This policy is not applicable to any information collected offline or via channels other than this website.</p>

      <h2>Consent</h2>
      <p>By using our website, you hereby consent to our Privacy Policy and agree to its Terms and Conditions.</p>

      <h2>Changes to This Privacy Policy</h2>
      <p>We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.</p>

      <Link to="/" className="back-to-home">← Back to Home</Link>
    </div>
  );
};

export default PrivacyPolicy; 