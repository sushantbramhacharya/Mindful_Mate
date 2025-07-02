import { useEffect, useState } from "react";

function ExerciseManager() {
  const [exerciseList, setExerciseList] = useState([]);
  const [filteredExercises, setFilteredExercises] = useState([]);
  const [videoFile, setVideoFile] = useState(null);
  const [exerciseName, setExerciseName] = useState("");
  const [category, setCategory] = useState("");
  const [duration, setDuration] = useState("");
  const [difficulty, setDifficulty] = useState("Beginner");
  const [description, setDescription] = useState("");
  const [instructions, setInstructions] = useState("");
  const [loading, setLoading] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState("All");

  // For edit
  const [editingExerciseId, setEditingExerciseId] = useState(null);
  const [editExerciseName, setEditExerciseName] = useState("");
  const [editCategory, setEditCategory] = useState("");
  const [editDuration, setEditDuration] = useState("");
  const [editDifficulty, setEditDifficulty] = useState("Beginner");
  const [editDescription, setEditDescription] = useState("");
  const [editInstructions, setEditInstructions] = useState("");

  const API_URL = "http://localhost:5000";

  const fetchExercises = async () => {
    try {
      const res = await fetch(`${API_URL}/exercises`);
      const data = await res.json();
      setExerciseList(data);
      setFilteredExercises(data);
    } catch (err) {
      console.error("Failed to fetch exercise list", err);
    }
  };

  useEffect(() => {
    fetchExercises();
  }, []);

  useEffect(() => {
    if (selectedCategory === "All") {
      setFilteredExercises(exerciseList);
    } else {
      setFilteredExercises(
        exerciseList.filter(
          (e) => e.category.toLowerCase() === selectedCategory.toLowerCase()
        )
      );
    }
  }, [selectedCategory, exerciseList]);

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!videoFile || !exerciseName || !category || !duration) {
      alert("Please fill all required fields.");
      return;
    }

    setLoading(true);
    const formData = new FormData();
    formData.append("video", videoFile);
    formData.append("exerciseName", exerciseName);
    formData.append("category", category);
    formData.append("duration", duration);
    formData.append("difficulty", difficulty);
    formData.append("description", description);
    formData.append("instructions", instructions);

    try {
      const res = await fetch(`${API_URL}/upload-exercise`, {
        method: "POST",
        body: formData,
      });

      const data = await res.json();
      alert(data.message || "Exercise uploaded successfully");
      resetForm();
      fetchExercises();
    } catch (err) {
      console.error("Upload error", err);
      alert("Upload failed");
    } finally {
      setLoading(false);
    }
  };

  const resetForm = () => {
    setExerciseName("");
    setCategory("");
    setDuration("");
    setDifficulty("Beginner");
    setDescription("");
    setInstructions("");
    setVideoFile(null);
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this exercise permanently?")) return;

    try {
      const res = await fetch(`${API_URL}/exercises/${id}`, {
        method: "DELETE",
      });
      const data = await res.json();
      alert(data.message || "Exercise deleted");
      fetchExercises();
    } catch (err) {
      console.error("Delete error", err);
      alert("Deletion failed");
    }
  };

  const startEdit = (exercise) => {
    setEditingExerciseId(exercise._id);
    setEditExerciseName(exercise.exercise_name);
    setEditCategory(exercise.category);
    setEditDuration(exercise.duration);
    setEditDifficulty(exercise.difficulty);
    setEditDescription(exercise.description || "");
    setEditInstructions(exercise.instructions?.join("\n") || "");
  };

  const cancelEdit = () => {
    setEditingExerciseId(null);
  };

  const saveEdit = async (id) => {
    if (!editExerciseName || !editCategory || !editDuration) {
      alert("Please fill all required fields.");
      return;
    }

    try {
      const res = await fetch(`${API_URL}/exercises/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          exerciseName: editExerciseName,
          category: editCategory,
          duration: editDuration,
          difficulty: editDifficulty,
          description: editDescription,
          instructions: editInstructions
        }),
      });

      if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.error || "Update failed");
      }

      const data = await res.json();
      alert(data.message || "Exercise updated successfully");
      fetchExercises();
      cancelEdit();
    } catch (err) {
      console.error("Edit error", err);
      alert(err.message || "Update failed");
    }
  };

  const categories = ["All", ...new Set(exerciseList.map((e) => e.category))];
  const difficultyLevels = ["Beginner", "Intermediate", "Advanced"];

  return (
    <div className="max-w-4xl mx-auto p-4">
      <h1 className="text-2xl font-bold mb-6 text-center">
        🏋️ Exercise Manager
      </h1>

      {/* Upload Form */}
      <form
        onSubmit={handleUpload}
        className="bg-white p-4 rounded-lg shadow mb-6"
      >
        <h2 className="text-lg font-semibold mb-3">Add New Exercise</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div>
            <label className="block mb-1 font-medium">Exercise Video*</label>
            <input
              type="file"
              accept="video/*"
              onChange={(e) => setVideoFile(e.target.files[0])}
              required
              className="w-full p-2 border rounded"
            />
          </div>
          <div>
            <label className="block mb-1 font-medium">Exercise Name*</label>
            <input
              type="text"
              value={exerciseName}
              onChange={(e) => setExerciseName(e.target.value)}
              placeholder="Morning Stretch"
              required
              className="w-full p-2 border rounded"
            />
          </div>
          <div>
            <label className="block mb-1 font-medium">Category*</label>
            <input
              type="text"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              placeholder="Stretching"
              required
              className="w-full p-2 border rounded"
            />
          </div>
          <div>
            <label className="block mb-1 font-medium">Duration*</label>
            <input
              type="text"
              value={duration}
              onChange={(e) => setDuration(e.target.value)}
              placeholder="10 min"
              required
              className="w-full p-2 border rounded"
            />
          </div>
          <div>
            <label className="block mb-1 font-medium">Difficulty</label>
            <select
              value={difficulty}
              onChange={(e) => setDifficulty(e.target.value)}
              className="w-full p-2 border rounded"
            >
              {difficultyLevels.map((level) => (
                <option key={level} value={level}>
                  {level}
                </option>
              ))}
            </select>
          </div>
          <div className="md:col-span-2">
            <label className="block mb-1 font-medium">Description</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Brief description of the exercise"
              className="w-full p-2 border rounded"
              rows="2"
            />
          </div>
          <div className="md:col-span-2">
            <label className="block mb-1 font-medium">Instructions (one per line)</label>
            <textarea
              value={instructions}
              onChange={(e) => setInstructions(e.target.value)}
              placeholder="Step 1: Stand straight\nStep 2: Reach arms overhead..."
              className="w-full p-2 border rounded"
              rows="4"
            />
          </div>
        </div>
        <button
          type="submit"
          disabled={loading}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:bg-gray-400"
        >
          {loading ? "Uploading..." : "Upload Exercise"}
        </button>
      </form>

      {/* Filter */}
      <div className="mb-4 flex items-center">
        <label className="mr-2 font-medium">Filter:</label>
        <select
          value={selectedCategory}
          onChange={(e) => setSelectedCategory(e.target.value)}
          className="p-2 border rounded"
        >
          {categories.map((cat) => (
            <option key={cat} value={cat}>
              {cat}
            </option>
          ))}
        </select>
      </div>

      {/* Exercise List */}
      <div className="space-y-4">
        {filteredExercises.length === 0 ? (
          <p className="text-center text-gray-500 py-4">No exercises found</p>
        ) : (
          filteredExercises.map((exercise) => {
            const videoSrc = `${API_URL}/uploads/exercise_videos/${exercise.file_path
              ?.split("/")
              .pop()}`;
            const isEditing = editingExerciseId === exercise._id;

            return (
              <div
                key={exercise._id}
                className="bg-white p-4 rounded-lg shadow"
              >
                {isEditing ? (
                  <div className="space-y-3">
                    <input
                      type="text"
                      value={editExerciseName}
                      onChange={(e) => setEditExerciseName(e.target.value)}
                      className="w-full p-2 border rounded font-bold text-lg"
                    />
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                      <input
                        type="text"
                        value={editCategory}
                        onChange={(e) => setEditCategory(e.target.value)}
                        className="p-2 border rounded"
                      />
                      <input
                        type="text"
                        value={editDuration}
                        onChange={(e) => setEditDuration(e.target.value)}
                        className="p-2 border rounded"
                      />
                      <select
                        value={editDifficulty}
                        onChange={(e) => setEditDifficulty(e.target.value)}
                        className="p-2 border rounded"
                      >
                        {difficultyLevels.map((level) => (
                          <option key={level} value={level}>
                            {level}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="md:col-span-3">
                      <label className="block mb-1 font-medium">Description</label>
                      <textarea
                        value={editDescription}
                        onChange={(e) => setEditDescription(e.target.value)}
                        className="w-full p-2 border rounded"
                        rows="2"
                      />
                    </div>
                    <div className="md:col-span-3">
                      <label className="block mb-1 font-medium">Instructions (one per line)</label>
                      <textarea
                        value={editInstructions}
                        onChange={(e) => setEditInstructions(e.target.value)}
                        className="w-full p-2 border rounded"
                        rows="4"
                      />
                    </div>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => saveEdit(exercise._id)}
                        className="bg-green-600 text-white px-4 py-1 rounded"
                      >
                        Save
                      </button>
                      <button
                        onClick={cancelEdit}
                        className="bg-gray-500 text-white px-4 py-1 rounded"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <div className="space-y-2">
                    <h3 className="font-bold text-lg">
                      {exercise.exercise_name}
                    </h3>
                    <div className="flex flex-wrap gap-2">
                      <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm">
                        {exercise.category}
                      </span>
                      <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-sm">
                        {exercise.duration}
                      </span>
                      <span
                        className={`px-2 py-1 rounded text-sm ${
                          exercise.difficulty === "Beginner"
                            ? "bg-green-100 text-green-800"
                            : exercise.difficulty === "Intermediate"
                            ? "bg-yellow-100 text-yellow-800"
                            : "bg-red-100 text-red-800"
                        }`}
                      >
                        {exercise.difficulty}
                      </span>
                    </div>
                    {exercise.description && (
                      <div className="text-gray-700">
                        <p>{exercise.description}</p>
                      </div>
                    )}
                    {exercise.instructions?.length > 0 && (
                      <div className="text-gray-700">
                        <h4 className="font-medium">Steps:</h4>
                        <ol className="list-decimal pl-5">
                          {exercise.instructions.map((step, i) => (
                            <li key={i}>{step}</li>
                          ))}
                        </ol>
                      </div>
                    )}
                    <div className="flex space-x-2 mt-2">
                      <button
                        onClick={() => startEdit(exercise)}
                        className="bg-yellow-500 text-white px-3 py-1 rounded text-sm"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => handleDelete(exercise._id)}
                        className="bg-red-500 text-white px-3 py-1 rounded text-sm"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                )}

                {/* Video Player */}
                <div className="mt-3">
                  <video
                    controls
                    className="w-full rounded-lg border"
                    src={videoSrc}
                  >
                    Your browser doesn't support HTML5 video
                  </video>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}

export default ExerciseManager;