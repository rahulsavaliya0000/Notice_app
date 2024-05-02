import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowNoticesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notices'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('review').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ReviewCard(
                reviewerName: 'COLLEGE AUTHORITY',
                reviewedPlace: data['title'] ?? "$index",
                reviewSnippet: data['description'] ?? "There is Nothing.",
                imageUrl: data['image_url'] ?? 'https://imgs.search.brave.com/jQZwxbtizj_l36g9FsUsDscLdaY1hUm9NYpeY_why3k/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzAxLzM4LzIzLzM4/LzM2MF9GXzEzODIz/Mzg5MV9UZ2xOMXNI/THA2M2ZJNGowTloy/STZyZHRKaVYwdG1K/RC5qcGc',
                category: 'Food & Drink',
                location: 'Secang Yogyakarta',
                likes: 68,

                shares: 3,
                id: data['id'] ?? "$index",
              );
            },
          );
        },
      ),
    );
  }
}

class ReviewCard extends StatefulWidget {
  final String reviewerName;
  final String reviewedPlace;
  final String reviewSnippet;
  final String imageUrl;
  final String category;
  final String location;
  final int likes;
  final int shares;
  final String id;

  ReviewCard({
    required this.reviewerName,
    required this.reviewedPlace,
    required this.reviewSnippet,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.likes,
    required this.shares,
    required this.id,
  });

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool isLiked = false;
  late Stream<QuerySnapshot> fire_ref;
  CollectionReference ref = FirebaseFirestore.instance.collection("review");
  int like = 0;

  @override
  void initState() {
    super.initState();
    fire_ref = FirebaseFirestore.instance
        .collection("review")
        .doc(widget.id)
        .collection("comments")
        .snapshots();
    loadLikedStatus();
  }

  Future<void> loadLikedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      isLiked = prefs.getBool(widget.id) ?? false;
    });

    // Fetch the like count from Firestore
    DocumentSnapshot doc = await ref.doc(widget.id).get();
    if (!mounted) return; // Check if the widget is still mounted
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        like = data['likes'] ?? 0;
      });
    }
  }



  Future<void> saveLikedStatus(bool isLiked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widget.id, isLiked);
  }

  void updateLikeCount(bool isLiked) async {
    setState(() {
      like = isLiked ? like + 1 : like - 1;
    });

    // Update the like count in Firestore
    await ref.doc(widget.id).update({"likes": like});

    saveLikedStatus(isLiked);
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewDetailPage(
              imageUrl: widget.imageUrl,
              reviewedPlace: widget.reviewedPlace,
              reviewerName: widget.reviewerName,
              reviewSnippet: widget.reviewSnippet,
              id: widget.id,
            ),
          ),
        );
      },
      child: Card(
        elevation: 10,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: widget.imageUrl, // Use the same tag as in ReviewDetailPage
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrl,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.reviewedPlace,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
        
                  Container(
                    width: MediaQuery.of(context).size.width - 48,
                    child: Text(
                      widget.reviewSnippet,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () {
                              setState(() {
                                isLiked = !isLiked; // Toggle the like status
                                updateLikeCount(isLiked); // Update the like count in Firebase
                              });
                            },
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("review")
                                .doc(widget.id)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CupertinoActivityIndicator();
                              }

                              var data = snapshot.data!.data() as Map<String, dynamic>;
                              int likeCount = data['likes'] ?? 0; // Get the like count from Firebase
                              return Text('$likeCount Likes'); // Display the updated like count
                            },
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Icon(Icons.comment),
                          StreamBuilder<QuerySnapshot>(
                            stream: fire_ref,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CupertinoActivityIndicator());
                              }

                              int commentCount = snapshot.data!.docs.length; // Get the comment count
                              return Text(
                                'comments ($commentCount)',
                                // Display the comment count
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class ReviewDetailPage extends StatefulWidget {
  final String imageUrl;
  final String reviewedPlace;
  final String reviewerName;
  final String id;
  final String reviewSnippet;

  const ReviewDetailPage({
    Key? key,
    required this.imageUrl,
    required this.reviewedPlace,
    required this.reviewerName,
    required this.reviewSnippet,
    required this.id,
  }) : super(key: key);

  @override
  _ReviewDetailPageState createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  late Stream<QuerySnapshot> fire_ref;
  CollectionReference ref = FirebaseFirestore.instance.collection("review");
  int like = 0;
  Map<String, bool> isCommentLiked = {};
  late SharedPreferences prefs;
  List<String> commentIds = [];

  @override
  void initState() {
    super.initState();
    fire_ref = FirebaseFirestore.instance
        .collection("review")
        .doc(widget.id)
        .collection("comments")
        .snapshots();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    loadCommentIds();
  }

  Future<void> loadCommentIds() async {
    QuerySnapshot snapshot =
    await ref.doc(widget.id).collection("comments").get();
    List<String> ids = snapshot.docs.map((doc) => doc.id).toList();
    setState(() {
      commentIds = ids;
    });
    loadLikedStatus();
  }

  Future<void> loadLikedStatus() async {
    if (!mounted) return;
    for (String commentId in commentIds) {
      bool isLiked = prefs.getBool(commentId) ?? false;
      setState(() {
        isCommentLiked[commentId] = isLiked;
      });
    }
  }

  void updateLikeCount(bool isLiked, String commentId, int currentLikes) async {
    // Update local like count first
    setState(() {
      like = isLiked ? like + 1 : like - 1;
    });

    // Update the like count in Firestore
    await ref
        .doc(widget.id)
        .collection("comments")
        .doc(commentId)
        .update({'likes': currentLikes + (isLiked ? 1 : -1)});

    // Save liked status locally
    await prefs.setBool(commentId, isLiked);
    setState(() {
      isCommentLiked[commentId] = isLiked;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notice Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: Hero(
                      tag: widget.imageUrl,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reviewedPlace,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      
                        SizedBox(height: 8),
                        Text(widget.reviewSnippet),
                        SizedBox(height: 16),
                        Text('Notice by: ${widget.reviewerName}'),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Comment",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(width: 8),
                              // Add some space between the text and the comment count
                              StreamBuilder<QuerySnapshot>(
                                stream: fire_ref,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CupertinoActivityIndicator());
                                  }

                                  int commentCount = snapshot.data!.docs.length;
                                  return Text(
                                    'comments ($commentCount)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        StreamBuilder<QuerySnapshot>(
                          stream: fire_ref,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No comments yet'));
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> commentData =
                                snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                                String commentText =
                                    commentData['comment'] ?? "Comment is null";
                                String userId =
                                    commentData['user_id'] ?? "User ID is null";
                                String commentId =
                                    snapshot.data!.docs[index].id;
                                int likes = commentData['likes'] ?? 0;

                                return ListTile(
                                  title: Text(commentText),
                                  subtitle: Text('User ID: $userId'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(likes.toString()),
                                      IconButton(
                                        icon: Icon(
                                          isCommentLiked[commentId] ?? false ? Icons.favorite : Icons.favorite_border,
                                          color: isCommentLiked[commentId] ?? false ? Colors.red : null,
                                        ),
                                        onPressed: () {
                                          bool? isLiked = isCommentLiked[commentId];
                                          if (isLiked != null) {
                                            updateLikeCount(!isLiked, commentId, likes);
                                          }
                                        },
                                      ),

                                    ],
                                  ),
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Delete Comment'),
                                        content: Text(
                                            'Are you sure you want to delete this comment?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              ref
                                                  .doc(widget.id)
                                                  .collection("comments")
                                                  .doc(commentId)
                                                  .delete();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black),
              ),
            ),
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                contentPadding:
                EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _submitComment(widget.id);
                  },
                ),
              ),
              onSubmitted: (value) {
                _submitComment(widget.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitComment(String userId) {
    String commentText = _commentController.text.trim();
    String commentId = DateTime.now().microsecondsSinceEpoch.toString();
    if (commentText.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('review')
          .doc(userId)
          .collection('comments')
          .doc(commentId)
          .set({
        'comment': commentText,
        'user_id': userId,
        'id': commentId,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        setState(() {
          _commentController.clear();
        });
      }).catchError((error) {
        print('Error adding comment: $error');
      });
    }
  }
}